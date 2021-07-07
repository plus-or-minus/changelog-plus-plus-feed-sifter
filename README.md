# changelog +/- a few things

[Changelog](https://changelog.com/) has a collection of excellent, free [podcast shows](https://changelog.com/podcasts) with an option to subscribe
on a recurring basis in order to support them.

> You love our content and you want to take it to the next level by showing your support. We'll take you closer to the metal with no ads, extended episodes, outtakes, bonus content, a deep discount in our merch store (soon), and more to come. Let's do this!

When you *upgrade* to Changelog++ you're given access to ad-free versions of episodes however they're only available in one giant bucket feed instead of through individual show feeds. Though only around 5 new podcast episodes are published weekly, if you're coming in as a new listener you'll have a long backlog list with over one thousand shows. It's easier to sift through older episodes when they're organized by show, so that's what this project provides: individual show feeds.

## Requirements

  * [Changelog++ subscription](https://changelog.com/++)
  * Ruby
  * [nokogiri gem](https://rubygems.org/gems/nokogiri)

## Limitations

  * The URLs to the generated feeds in your private GitHub repository are only accessible by clients that support basic authentication. Overcast works but Apple Podcasts doesn't.

## Instructions

### Running as a GitHub Action

**WARNING**
DO NOT FORK this project because your project will be public and paid
Changelog++ subscriber content will be publicly available in the repository.
Please make sure your repository's visibility is set to **private**.

1. Clone this GitHub project to your account
2. Create a `generated` branch
3. Generate a personal GitHub access token at https://github.com/settings/tokens
4. Add the `GH_PERSONAL_ACCESS_TOKEN` secret to the project (in Settings > Secrets) with the personal GitHub access token you just generated as the value
5. Open https://changelog.supercast.tech/subscriber/new_player_links (requires login) and copy the "Get RSS Link" url
6. Add the `CHANGELOG_PLUS_PLUS_FEED_URL` secret to the project (in Settings > Secrets)
7. Uncomment the schedule settings in `.github/workflows/generate-feeds.yml` and commit the changes
8. Access your feeds at `https://GH_PERSONAL_ACCESS_TOKEN@raw.githubusercontent.com/GH_USERNAME/GH_PROJECT/generated/feeds/CHANGELOG_SHOW_KEY.xml` or import `feeds.opml` into your feed reader

Your feeds will be updated every 15 minutes.

### Running locally

1. Open https://changelog.supercast.tech/subscriber/new_player_links (requires login)
2. Click the "Get RSS Link" button and copy the URL
3. Open your terminal app
4. Run `export CHANGELOG_PLUS_PLUS_FEED_URL=replace_with_the_supercast_url` (replace the url)
5. Run `make run`
6. Feeds will be generated in the `feeds/` directory

## [Changelog++ Shows](https://changelog.com/podcasts)

  * Away from Keyboard
  * Backstage
  * Brain Science
  * Founders Talk
  * Go Time
  * JS Party
  * Practical AI
  * Request For Commits
  * Ship It!
  * Spotlight
  * The Changelog
  * The React Podcast

See https://changelog.com/podcasts for a list of podcasts.
