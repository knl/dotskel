# Custom jj-vcs segment for p10k
# In order to make it I took inspiration from these posts:
# - https://zerowidth.com/2025/async-zsh-jujutsu-prompt-with-p10k/
# - https://andre.arko.net/2025/06/20/a-jj-prompt-for-powerlevel10k/

typeset -g _jj_vcs_display=""
typeset -g _jj_vcs_workspace=""

prompt_jj_vcs() {
  local workspace

  # Here we verify that jj is installed and that we are in a jj workspace
  command -v jj >/dev/null 2>&1 || return
  if workspace=$(jj workspace root 2>/dev/null); then
    p10k display "*/jj-vcs=show"
    p10k display "*/vcs=hide"
  else
    p10k display "*/jj-vcs=hide"
    p10k display "*/vcs=show"
    return
  fi

  # Here we track the workspace to prevent stale cache, as we are using async jobs
  if [[ $_jj_vcs_workspace != "$workspace" ]]; then
    _jj_vcs_display=""
    _jj_vcs_workspace="$workspace"
  fi

  # Here we start the async job
  async_job _jj_vcs_worker _jj_vcs_async "$workspace"

  # Here we render the segment
  p10k segment -t '$_jj_vcs_display' -e
}

# jj prompt table of contents:
# ----------------------------
# jj_add     | add changes to jj for this prompt   | (no output)
# jj_at      | bookmark name and distance from @   | main›1
# jj_remote  | count changes ahead/behind remote   | 2⇡1⇣
# jj_change  | the current jj change ID            | kkor
# jj_desc    | current change description          | first line of description (or  )
# jj_status  | counts of added, removed, modified  | +1 -4 ^2 
# jj_op      | the current jj operation ID         | b44825e56a5a


# Async job function
# Its function is to extract the necessary information from the jj workspace and build the segment display string
_jj_vcs_async() {
  local workspace=$1
  local max_depth=${JJ_PROMPT_MAX_DEPTH:-80} # override to search deeper ancestry if needed

    local grey='%244F'
    local green='%2F'
    local blue='%39F'
    local red='%196F'
    local yellow='%3F'
    local cyan='%6F'
    local magenta='%5F'

    ## jj_add
    jj --repository "$workspace" --at-operation=@ debug snapshot


    ## jj_at
    local branch=$(jj --repository "$workspace" --ignore-working-copy --at-op=@ --no-pager log --no-graph --limit 1 -r "
      coalesce(
        heads(::@ & (bookmarks() | remote_bookmarks() | tags())),
        heads(@:: & (bookmarks() | remote_bookmarks() | tags())),
        trunk()
      )" -T "separate(' ', bookmarks, tags)" 2> /dev/null | cut -d ' ' -f 1)
    if [[ -n $branch ]]; then
      [[ $branch =~ "\*$" ]] && branch=${branch::-1}

      local VCS_STATUS_COMMITS_AFTER=$(jj --ignore-working-copy --at-op=@ --no-pager log --no-graph -r "$branch..@ & (~empty() | merges())" -T '"n"' 2> /dev/null | wc -c | tr -d ' ')
      local VCS_STATUS_COMMITS_BEFORE=$(jj --ignore-working-copy --at-op=@ --no-pager log --no-graph -r "@..$branch & (~empty() | merges())" -T '"n"' 2> /dev/null | wc -c | tr -d ' ')
      local counts=($(jj --repository "$workspace" --ignore-working-copy --at-op=@ --no-pager bookmark list -r $branch -T '
        if(remote,
          separate(" ",
            name ++ "@" ++ remote, 
            coalesce(tracking_ahead_count.exact(), tracking_ahead_count.lower()),
            coalesce(tracking_behind_count.exact(), tracking_behind_count.lower()),
            if(tracking_ahead_count.exact(), "0", "+"),
            if(tracking_behind_count.exact(), "0", "+"),
          ) ++ "\n"
        )
      '))

      local VCS_STATUS_LOCAL_BRANCH=$branch
      local VCS_STATUS_COMMITS_AHEAD=$counts[2]
      local VCS_STATUS_COMMITS_BEHIND=$counts[3]
      local VCS_STATUS_COMMITS_AHEAD_PLUS=$counts[4]
      local VCS_STATUS_COMMITS_BEHIND_PLUS=$counts[5]
    fi

    local status_color=${green}
    (( VCS_STATUS_COMMITS_AHEAD )) && status_color=${cyan}
    (( VCS_STATUS_COMMITS_BEHIND )) && status_color=${magenta}
    (( VCS_STATUS_COMMITS_AHEAD && VCS_STATUS_COMMITS_BEHIND )) && status_color=${red}

    local res
    local where=${(V)VCS_STATUS_LOCAL_BRANCH}
    # If local branch name or tag is at most 32 characters long, show it in full.
    # Otherwise show the first 12 … the last 12.
    (( $#where > 32 )) && where[13,-13]="…"
    res+="${status_color}${where//\%/%%}"  # escape %

    # ‹42 if before the local bookmark
    (( VCS_STATUS_COMMITS_BEFORE )) && res+="‹${VCS_STATUS_COMMITS_BEFORE}"
    # ›42 if beyond the local bookmark
    (( VCS_STATUS_COMMITS_AFTER )) && res+="›${VCS_STATUS_COMMITS_AFTER}"


    ## jj_remote
    # # ⇣42 if behind the remote.
    # (( VCS_STATUS_COMMITS_BEHIND )) && res+=" ${green}⇣${VCS_STATUS_COMMITS_BEHIND}"
    # (( VCS_STATUS_COMMITS_BEHIND_PLUS )) && res+="${VCS_STATUS_COMMITS_BEHIND_PLUS}"
    # # ⇡42 if ahead of the remote; no leading space if also behind the remote: ⇣42⇡42.
    # (( VCS_STATUS_COMMITS_AHEAD && !VCS_STATUS_COMMITS_BEHIND )) && res+=" "
    # (( VCS_STATUS_COMMITS_AHEAD  )) && res+="${green}⇡${VCS_STATUS_COMMITS_AHEAD}"
    # (( VCS_STATUS_COMMITS_AHEAD_PLUS )) && res+="${VCS_STATUS_COMMITS_AHEAD_PLUS}"


    ## jj_change
    IFS="#" local change=($(jj --repository "$workspace" --ignore-working-copy --at-op=@ --no-pager log --no-graph --limit 1 -r "@" -T '
      separate("#", change_id.shortest(4).prefix(), coalesce(change_id.shortest(4).rest(), "\0"),
        commit_id.shortest(4).prefix(),
        coalesce(commit_id.shortest(4).rest(), "\0"),
        concat(
          if(conflict, "💥"),
          if(divergent, "🚧"),
          if(hidden, "👻"),
          if(immutable, "🔒"),
        ),
      )'))
    local VCS_STATUS_CHANGE=($change[1] $change[2])
    local VCS_STATUS_COMMIT=($change[3] $change[4])
    local VCS_STATUS_ACTION=$change[5]
    # 'zyxw' with the standard jj color coding for shortest name
    res+=" ${magenta}${VCS_STATUS_CHANGE[1]}${grey}${VCS_STATUS_CHANGE[2]}"
    # '💥🚧👻🔒' if the repo is in an unusual state.
    [[ -n $VCS_STATUS_ACTION     ]] && res+=" ${red}${VCS_STATUS_ACTION}"
    # # '123abc' with the standard jj color coding for shortest name
    # res+=" ${blue}${VCS_STATUS_COMMIT[1]}${grey}${VCS_STATUS_COMMIT[2]}"


    ## jj_desc
    # local VCS_STATUS_MESSAGE=$(jj --repository "$workspace" --ignore-working-copy --at-op=@ --no-pager log --no-graph --limit 1 -r "@" -T "coalesce(description.first_line(), if(!empty, '\Uf040 '))")
    # [[ -n $VCS_STATUS_MESSAGE ]] && res+=" ${green}${VCS_STATUS_MESSAGE}"
    

    ## jj_status
    local VCS_STATUS_CHANGES=($(jj --repository "$workspace" log --ignore-working-copy --at-op=@ --no-graph --no-pager -r @ -T "diff.summary()" 2> /dev/null | awk 'BEGIN {a=0;d=0;m=0} /^A / {a++} /^D / {d++} /^M / {m++} /^R / {m++} /^C / {a++} END {print(a,d,m)}'))
    (( VCS_STATUS_CHANGES[1] )) && res+=" %F{green}+${VCS_STATUS_CHANGES[1]}"
    (( VCS_STATUS_CHANGES[2] )) && res+=" %F{red}-${VCS_STATUS_CHANGES[2]}"
    (( VCS_STATUS_CHANGES[3] )) && res+=" ${yellow}^${VCS_STATUS_CHANGES[3]}"


    ## jj_op
    # local VCS_STATUS_MESSAGE=$(jj --ignore-working-copy --at-op=@ --no-pager op log --limit 1 --no-graph -T "id.short()")
    # [[ -n $VCS_STATUS_MESSAGE ]] && res+=" ${blue}${VCS_STATUS_MESSAGE}"


    # return results
    echo $res
}

# Async callback function
# This function is called when the async job is done
# It updates the display variable and triggers a prompt redraw
_jj_vcs_callback() {
  local job_name=$1 exit_code=$2 output=$3 execution_time=$4 stderr=$5 next_pending=$6
  if [[ $exit_code == 0 ]]; then
    _jj_vcs_display=$output
  else
    # Fallback on error
    _jj_vcs_display="%F{red}err%f"
  fi
  p10k display -r
}

async_init
async_stop_worker _jj_vcs_worker 2>/dev/null
async_start_worker _jj_vcs_worker
async_unregister_callback _jj_vcs_worker 2>/dev/null
async_register_callback _jj_vcs_worker _jj_vcs_callback
