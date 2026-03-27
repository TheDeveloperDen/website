# Devden website
> 🌳  built with [elm-spa](https://elm-spa.dev)

## dependencies

This project requires the latest LTS version of [Node.js](https://nodejs.org/)

```bash
npm install -g elm elm-spa
```

## running locally

```bash
elm-spa server  # starts this app at http:/localhost:1234
devenv up # also starts the app, but automatically takes care of everything

```

### other commands

```bash
elm-spa add    # add a new page to the application
elm-spa build  # production build
elm-spa watch  # runs build as you code (without the server)
```

**Formatting**:

```bash
treefmt  # formats everything
```

## learn more

You can learn more at [elm-spa.dev](https://elm-spa.dev)


## TODO

- [ ] Main page (index), shows information about the organisation with links to the discord server
- [ ] `/xp/leaderboard` - show the top N users in terms of XP and level (can query the API for this).
  See https://lb.helpch.at/ for inspiration. Maybe allow parameters like `?size=10` to show the top 10 users.
- [ ] `/stats/` - Shows various graphs with stats about the servers. We can decide on exactly the data we show later,
  but we have logs of all user joins, leaves and messages (with user IDs, timestamps, content, etc).
- [ ] `/projects/<projectname>` - Show information about a various project we have.
  Should follow a standard format and show github link, contributors (fetch from github?), and other information.
- [ ] `/faqs` - Show all the FAQs that you'd see in `ddfaq`
- [X] `/rules` - ~~pretty obvious, rules of the server. we can provide these in a json format if it helps~~
- [ ] `/team` or `/staff` - Show a nice list of admins, mods, contributors to projects, etc
- [ ] `/moderation/` Once the bot gets moderation features it would be very very cool to have a panel
  like Dyno or yagpdb have. This probably won't happen for a while.
