# Docker related

alias dcdev='docker-compose -f docker-compose.dev.yml'
find-container() {
  local container_name_contains="$1"
  local compose_file="${2:-docker-compose.dev.yml}"

  inline_global_ruby <<'END'
    ruby -e "require 'YAML'; puts YAML.load(File.read('$compose_file'))['services'].keys" | grep "$container_name_contains"
END
}

dcrun() {
  local container="$(find-container $1)"

  if [ -z "$container" ]; then
    echo "No container matching $1"
  elif [ $(echo "$container" | wc -l) -gt 1 ]; then
    echo "More than one container matching:"
    echo "$container"
  else
    local container_id="$(dcdev ps -q backend)"
    local alias=$(whence "${@:2}" || echo "${@:2}")
    local command="docker exec -it $container_id $alias"

    echo "Running $command"
    eval "$command"
  fi
}

dspec() {
  dcrun backend "spring rspec $1"
}

docker-remove-container-by-name() {
  local name="$1";

  docker ps -a | awk '{ print $1,$2 }' | grep "$name" | awk '{print $1 }' | xargs -I {} docker rm {}
}
