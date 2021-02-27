# Bash Shell Script Template

This is a template for initialize a utility shell script (bash), it works for me in most cases.

# Motivation: Use shell script to record everything.

Usually when I work with source code in a software project, no matter it is Java, Python or any other languages, there are some infrastructure set up tasks that need the use of shell scriptiing.

It is very useful to record EVERY shell commands that involve the source code. For example, when you initialize a NextJs project, you would write `yarn create next-app your-app`. It is not a waste of time to record this in a utility script so that you and your friend know EVERYTHING commands that involve the project.

```
#!/bin/bash

init_project() {
    yarn create next-app your-app
}
```

Suppose you have a command to be used in CI/CD configuration tools such as Gitlab CI, you write all the core command in this shell script and have Gitlab CI invoke your script.

```
# In your utility.sh
build_and_deploy_to_k8s() {
    yarn build
    build_docker_image
    publish_docker_image
    deploy_to_k8s
}

# In your .gitlab-ci.yml
deploy:
    stage: deploy
    script:
        - ./utility.sh build_and_deploy_to_k8s
```

With this practice, you verbosefully declare almost everything in the source code. The future you and your friends will share equal knowledge of what happen in the whole life cycle of the project and can investigate and reproduce any issue.

To do this, your `utility.sh` will need some common features:
1. You can add a new group of commands in a bash function and invoke the function easily, like `./utility.sh your_new_function`.
2. You can add documentation to your commands so that they can be shown when the user execute the script with `./utility.sh help` 
3. The `./utility.sh help` command can list all the available commands and their documentation.
4. You can add private commands that do not show to the user and cannot be invoked externally.
5. The script can handle when the user enter an invalid, or no command.
6. The script has easy error handling machanism.
7. The script is compliance with [shellcheck](https://github.com/koalaman/shellcheck) standard.

# How to use

1. Download the `template.sh` from this repository. For example `curl -O https://raw.githubusercontent.com/asinkxcoswt/shell-script-template/master/template.sh`

2. Create `your_shell_script.sh` and include the `template.sh` in it as follows

```
#!/bin/bash

source /path/to/template.sh
```

3. Add your command to `your_shell_script.sh` with the documentation, e.g.

```
#!/bin/bash

your_command() {
    _doc '
        What is this command for?\n
        How and when to invoke it?
    ' && return 1

    echo "Do the command logic"
}

source /path/to/template.sh
```

please notice that `&& return 1` at the end of `_doc` command. This is important to prevent `your_command` to be executed when the user run `./your_shell_script.sh help`.

4. Execute your command `./your_shell_script.sh your_command`
5. See `example.sh` to understand the error handling machanism and private command.
6. It is useful to lint `your_shell_script.sh` with [shellcheck](https://github.com/koalaman/shellcheck), e.g. `shellcheck your_shell_script.sh`.

# Example

```
ex_happy() {
    _doc '
        Test happy case
    ' && return 1

    echo "I am happy"
}

ex_unhappy() {
    _doc '
        Test the "error" command
    ' && return 1

    echo "Sad" && error "I am not happy"
}

ex_success_or_failure() {
    _doc '
        This example show you the error handling behavior.\n
        You can use || and && to handle in case your command fails.\n
        If a command in a pipe fails, all the pipe also fails
    ' && return 1

    echo "success" | grep "success" && { 
        alert "I am success" 
    } || { 
        error "I am failed" 
    }

    echo "success" | grep "failure" | echo "Hahaha the pipe will fail because grep fail" && { 
        alert "I am success" 
    } || { 
        error "I am failed" 
    }
}

ex_oops() {
    _doc '
        What will happens when there is an error that your forgot to handle with && and ||
    ' && return 1

    echo "Invalid command? $(some_invalid_command)"
}

_private_command() {
    echo "I am private"
}

ex_public_command() {
    _doc "
        All function that starts with _ will now be listed and cannot be invoked externally.\n
        But you can still invoke the function inside the script itself.
    " && return 1

    alert "I am going to call _private_command"

    _private_command
}
```