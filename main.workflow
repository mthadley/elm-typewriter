workflow "CI" {
  on = "push"
  resolves = ["Build"]
}

action "Build" {
  uses = "docker://node:10"
  runs = "make"
}
