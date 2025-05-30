#!/bin/bash -eu

# see also: git_origin and git_clone

function git_sparse_checkout {
    local self=$(readlink -f "${BASH_SOURCE[0]}")
    local app=$(basename $self)
    local usage=\
"USAGE: ${app} repository-URL [branch] [project-directory] [[--] [list-of-files-or-directories]]
  where:
    'repository-URL' is a valid URL pointing to a Git repository.
    'branch' is a branch, atag or a commit id. Default: master.
    'project-directory' is a folder to be created and populated. Default: the project name.
    'list-of-files-or-directories' is a list of file names or directories separated by spaces.
  Examples:
    ${app} http://github.com/frgomes/bash-scripts -- README.md
    ${app} http://github.com/frgomes/bash-scripts develop -- README.md bin/
    ${app} http://github.com/frgomes/bash-scripts develop tmpdir -- README.md bin/ docs/"

    # obtain repository-URL, e.g.: http://github.com/frgomes/bash-scripts
    [[ $# != 0 ]] || (echo "${usage}" 1>&2 ; return 1)
    local arg=${1}
    [[ "${arg}" != "--" ]] || (echo "${usage}" 1>&2 ; return 1)
    local url="${arg}"
    [[ $# == 0 ]] || shift

    # obtain branch, which the default is master for historical reasons
    if [[ "${arg}" != "--" ]] ;then arg="${1:-master}" ;fi
    if [[ "${arg}" == "--" ]] ;then
      local tag=master
    else
      local tag="${arg}"
      [[ $# == 0 ]] || shift
    fi

    # obtain the project directory, which defaults to the repository name
    local prj=$(echo "$url" | sed 's:/:\n:g' | tail -1)

    if [[ "${arg}" != "--" ]] ;then arg="${1:-.}" ;fi
    if [[ "${arg}" == "--" || "${arg}" == "." ]] ;then
      local dir=$(readlink -f "./${prj}")
    else
      local dir=$(readlink -f "${arg}")
      [[ $# == 0 ]] || shift
    fi

    if [[ "${arg}" == "--" ]] ;then [[ $# == 0 ]] || shift; fi
    if [[ "${1:-}" == "--" ]] ;then [[ $# == 0 ]] || shift; fi

    # Note: any remaining arguments after these above are considered as a
    # list of files or directories to be downloaded. Names of directories
    # must be followed by a slash /.

    local sparse=true
    local opts='--depth=1'

    # now perform the sparse checkout
    mkdir -p "${dir}"
    git -C "${dir}" init
    git -C "${dir}" config core.sparseCheckout ${sparse}
    for path in $* ;do
        echo "${path}" >> ${dir}/.git/info/sparse-checkout
    done
    git -C "${dir}" remote add origin ${url}
    git -C "${dir}" fetch ${opts} origin ${tag}
    git -C "${dir}" checkout ${tag}
}

git_sparse_checkout $@