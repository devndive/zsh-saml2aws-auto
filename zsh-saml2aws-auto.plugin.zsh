alias s2a="saml2aws-auto"

aws_profile() {
  if [[ "$AWS_PROFILE" != "" ]];
  then
    # We got a profile
    local aws_icon='\uf52c'

    local result=$(grep "name: $AWS_PROFILE$" ~/.saml2aws-auto.yml)
    local time_diff=""

    if [[ ${result} != "" ]]; then
      # Profile is configured
      local current_timestamp=$(date +%s)
      local valid_until=$(grep -A2 "$AWS_PROFILE" ~/.saml2aws-auto.yml \
        | awk '{ if($1 == "valid_until:") { print $2 } }' \
        | tr -d '"')

      local valid_until_timestamp=$(TZ=GMT+0:00 date -j -f "%Y-%m-%dT%H:%M:%S+00:00" ${valid_until} +%s)

      if [[ $current_timestamp -le $valid_until_timestamp ]]; then
        # Token is still valid
        time_diff="~$(( ($valid_until_timestamp - $current_timestamp) / 60 ))min"
        FGC='%F{green}'
        COLOR='%K{green}%F{black}'
      else
        # Token expired
        FGC='%F{yellow}'
        COLOR='%K{yellow}%F{black}'
      fi
    else
      # Profile is not configured
      FGC='%F{red}'
      COLOR='%K{red}%F{black}'
    fi

    echo "%{$FGC%}\uE0B2%{$reset_color%}%{$COLOR%} ${aws_icon} $AWS_PROFILE ${time_diff} %{$reset_color%}"
  fi
}

RPROMPT='$(aws_profile)'
