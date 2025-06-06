# show help by default
default:
    @{{ just_executable() }} --list --justfile {{ justfile() }}

lint:
    ansible-lint .
