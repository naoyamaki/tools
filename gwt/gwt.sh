#!/bin/sh

set -e

# エラーメッセージを表示して終了
error_exit() {
    echo "Error: $1" >&2
    exit 1
}

# gwt new [branch_name] の処理
gwt_new() {
    local branch_name="$1"

    # gitリポジトリ直下であることを確認
    if [ ! -d ".git" ]; then
        error_exit "Not in a git repository root directory"
    fi

    # 現在のディレクトリ名を取得
    local repo_name=$(basename "$(pwd)")

    # 未commitの変更差分がある場合stash
    local stash_flag=0
    if [ -n "$(git status --porcelain)" ]; then
        stash_flag=1
        git stash -u
    fi

    # branch_nameに/がある場合/を-に置き換え
    branch_name_dir=$(echo "$branch_name" | tr '/' '-')

    # ワークツリー作成
    git worktree add -b "$branch_name" "../${branch_name_dir}/${repo_name}"

    # stashした変更を戻す
    if [ $stash_flag -eq 1 ]; then
        git stash pop
    fi
}

# gwt new [branch_name] --recursive [dir_1] [dir_2]... の処理
gwt_new_recursive() {
    local branch_name="$1"
    shift
    local directories=("$@")

    local original_dir="$(pwd)"

    for dir in "${directories[@]}"; do
        echo "Processing directory: $dir"
        cd "$original_dir"
        cd "$dir" || error_exit "Cannot change to directory: $dir"
        gwt_new "$branch_name"
    done

    cd "$original_dir"
}

# gwt rm [branch_name] の処理
gwt_rm() {
    local branch_name="$1"

    # 対象のワークツリーのパスを取得
    local target_dir=$(git worktree list | awk -v branch="[$branch_name]" '$3==branch {print $1}')

    if [ -z "$target_dir" ]; then
        error_exit "Worktree for branch '$branch_name' not found"
    fi

    # ワークツリーを削除
    git worktree remove -f "$target_dir"
}

# gwt rm -d [branch_name] の処理
gwt_rm_with_branch() {
    local branch_name="$1"

    # ワークツリーを削除
    gwt_rm "$branch_name"

    # ブランチも削除
    git branch -D "$branch_name"
}

# ヘルプを表示
show_help() {
    echo "Usage:"
    echo "  gwt new <branch_name>"
    echo "  gwt new <branch_name> --recursive <dir_1> [dir_2] ..."
    echo "  gwt rm <branch_name>"
    echo "  gwt rm -d <branch_name>"
}

# メイン処理
main() {
    if [ $# -eq 0 ]; then
        show_help
        exit 1
    fi

    local command="$1"
    shift

    case "$command" in
        -h|--help)
            show_help
            exit 0
            ;;
        new)
            if [ $# -eq 0 ]; then
                error_exit "Branch name is required"
            fi

            local branch_name="$1"
            shift

            if [ "$1" = "--recursive" ]; then
                shift
                if [ $# -eq 0 ]; then
                    error_exit "At least one directory is required with --recursive"
                fi
                gwt_new_recursive "$branch_name" "$@"
            else
                gwt_new "$branch_name"
            fi
            ;;
        rm)
            if [ "$1" = "-d" ]; then
                shift
                if [ $# -eq 0 ]; then
                    error_exit "Branch name is required"
                fi
                gwt_rm_with_branch "$1"
            else
                if [ $# -eq 0 ]; then
                    error_exit "Branch name is required"
                fi
                gwt_rm "$1"
            fi
            ;;
        *)
            error_exit "Unknown command: $command"
            ;;
    esac
}

main "$@"
