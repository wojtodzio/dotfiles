# Docker related

alias dcdev='docker-compose -f docker-compose.dev.yml'

# Find container matching given name part
find-container() {
  local container_name_contains="$1"
  local compose_file="${2:-docker-compose.dev.yml}"

  inline_global_ruby <<'END'
    ruby -r yaml -e "puts YAML.load(File.read('$compose_file'))['services'].keys" | grep "$container_name_contains"
END
}

# Run command in containner of a given name part with resolving alias if command is single-worded
## TODO: Resolve whole command as on host system, e.g. change RET rdm to RAILS_ENV=test rake db:migrate
dcrun() {
  local container="$(find-container $1)"

  if [ -z "$container" ]; then
    echo "No container matching $1"
  elif [ $(echo "$container" | wc -l) -gt 1 ]; then
    echo "More than one container matching:"
    echo "$container"
  else
    local container_id="$(dcdev ps -q $container)"
    local command="docker exec -it $container_id ${@:2}"

    echo "Running $command"
    eval "$command"
  fi
}

# Run given spec in spring on backend
dspec() {
  dcrun backend "spring rspec $1"
}

docker-remove-container-by-name() {
  local name="$1";

  docker ps -a | awk '{ print $1,$2 }' | grep "$name" | awk '{print $1 }' | xargs -I {} docker rm {}
}

keep-container-up() {
  local container="$(find-container $1)"
  local container_id="$(dcps -q $container)"
  local container_id_short="$(echo $container_id | awk 'BEGIN{FIELDWIDTHS="12"} {print $1}')"
  local interval="${2:-2}"

  while true
  do
    sleep $interval
    local containerStatus="$(docker ps G $container_id_short | awk '{ print $7 }')"
    if [[ "$containerStatus" != "Up" ]]; then
      echo "$(date): $containner is not up, restarting"
      dcup -d elasticsearch;
    fi
  done
}
