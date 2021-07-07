require "rubygems"
require "bundler/setup"

require "net/http"
require "nokogiri"

CHANGELOG_PLUS_PLUS_FEED_URL = ENV.fetch("CHANGELOG_PLUS_PLUS_FEED_URL")

PODCAST_SHOWS = {
  afk: "Away from Keyboard",
  backstage: "Backstage",
  brainscience: "Brain Science",
  founderstalk: "Founders Talk",
  gotime: "Go Time",
  jsparty: "JS Party",
  practicalai: "Practical AI",
  rfc: "Request For Commits",
  shipit: "Ship It!",
  spotlight: "Spotlight",
  podcast: "The Changelog",
  reactpodcast: "The React Podcast"
}

FEED_OUTPUT_DIR = ENV.fetch("FEED_OUTPUT_DIR", "feeds")
CHANGELOG_EVERYTHING_FEED_FILENAME = ENV.fetch("CHANGELOG_EVERYTHING_FEED_FILENAME", "everything.xml")
CHANGELOG_FEED_LIST_OPML_FILENAME = ENV.fetch("CHANGELOG_FEED_LIST_OPML_FILENAME", "feeds.opml")
CHANGELOG_FEED_LIST_HTML_FILENAME = ENV.fetch("CHANGELOG_FEED_LIST_HTML_FILENAME", "feeds.html")
GH_REPOSITORY_NAME = ENV.fetch("GH_REPOSITORY_NAME", "example")
GH_OUTPUT_BRANCH_NAME = ENV.fetch("GH_OUTPUT_BRANCH_NAME", "generated")
GH_PERSONAL_ACCESS_TOKEN = ENV.fetch("GH_PERSONAL_ACCESS_TOKEN", "")

# create the feed output dir if specified
if !(FEED_OUTPUT_DIR.nil? || FEED_OUTPUT_DIR == "")
  Dir.mkdir(FEED_OUTPUT_DIR, 0o700) unless File.exist?(FEED_OUTPUT_DIR)
end

# read the Changelog++ everything feed that contains all episodes for all shows
puts "Reading the everything feed into memory"
original_doc = if ENV["LOCAL_FILE"]
  File.open(CHANGELOG_EVERYTHING_FEED_FILENAME) do |f|
    Nokogiri::XML(f)
  end
else
  uri = URI(CHANGELOG_PLUS_PLUS_FEED_URL)
  res = Net::HTTP.get_response(uri)
  if !res.code.to_i.between?(200, 399)
    puts "Failed to fetch feed from Changelog++"
    exit(1)
  end
  Nokogiri::XML(res.body)
end

# write the everything feed to file
File.open(File.join(FEED_OUTPUT_DIR, CHANGELOG_EVERYTHING_FEED_FILENAME), "w") do |f|
  original_doc.write_xml_to(f)
end

# create feeds for each show
PODCAST_SHOWS.each do |show_key, show_name|
  filename = [show_key, ".xml"].join
  puts "Creating feed for show \"#{show_name}\" (#{filename})"
  doc = original_doc.clone

  # update the feed title to include the show name
  doc.search("//channel/title").each do |node|
    node.content = "#{show_name} - #{node.content}"
  end

  # replace the feed url with a placeholder url since the content doesn't match anymore
  doc.search("//channel/atom:link").each do |node|
    node["href"] = "https://localhost/feeds/#{filename}"
  end

  # remove episodes not belonging to the show
  doc.search("//channel/item/title").each do |node|
    safe_show_name = Regexp.quote(show_name)

    # <title>Changelog++ launch thoughts (Backstage #13)</title>
    if !node.content.match?(/\(#{safe_show_name} #\d+\)/)
      node.remove
      next
    end

    puts "  * #{node.content}"
  end

  # write the feed to file
  File.open(File.join(FEED_OUTPUT_DIR, filename), "w") do |f|
    doc.write_xml_to(f)
  end
end

# generate feed list opml
opml = <<~'EOF'
    <?xml version="1.0" encoding="utf-8"?>
    <opml version="1.0">
      <head><title>Changelog++ Podcast Subscriptions</title></head>
      <body>
        <outline text="feeds">

  <REPLACE_WITH_FEEDS/>

        </outline>
      </body>
    </opml>
EOF

custom_feed_option = [GH_PERSONAL_ACCESS_TOKEN, GH_REPOSITORY_NAME, GH_OUTPUT_BRANCH_NAME].all? { |v| v.to_s != "" }

opml.gsub!(%r{<REPLACE_WITH_FEEDS/>}, PODCAST_SHOWS.collect { |show_key, show_name|
  feed_url = if custom_feed_option
    path = [GH_REPOSITORY_NAME, GH_OUTPUT_BRANCH_NAME, FEED_OUTPUT_DIR].compact.join("/")
    "https://#{GH_PERSONAL_ACCESS_TOKEN}@raw.githubusercontent.com/#{path}/#{show_key}.xml"
  else
    "https://changelog.com/#{show_key}/feed"
  end

  <<-EOF
        <outline type="rss" title="#{show_name}" text="https://changelog.com/#{show_key}/feed"
          xmlUrl="#{feed_url}" htmlUrl="https://changelog.com/#{show_key}"/>
  EOF
}.join("\n"))

# write the feed list opml to file
File.open(File.join(FEED_OUTPUT_DIR, CHANGELOG_FEED_LIST_OPML_FILENAME), "w") do |f|
  f.write(opml)
end

# generate feed list html
html = PODCAST_SHOWS.collect { |show_key, show_name|
  feed_url = if custom_feed_option
    path = [GH_REPOSITORY_NAME, GH_OUTPUT_BRANCH_NAME, FEED_OUTPUT_DIR].compact.join("/")
    "https://#{GH_PERSONAL_ACCESS_TOKEN}@raw.githubusercontent.com/#{path}/#{show_key}.xml"
  else
    "https://changelog.com/#{show_key}/feed"
  end

  "<a href=\"#{feed_url}\">#{show_name} (#{show_key})</a>"
}.join("<br>\n")

# write the feed list html to file
File.open(File.join(FEED_OUTPUT_DIR, CHANGELOG_FEED_LIST_HTML_FILENAME), "w") do |f|
  f.write(html)
end
