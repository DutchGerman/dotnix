let window = (niri msg --json windows | from json | where { |window|
  (($window.app_id? | default "" | str lowercase) == "mattermost.desktop")
} | get 0?)

if ($window | is-empty) {
  exit 1
}

niri msg action focus-window --id $window.id
