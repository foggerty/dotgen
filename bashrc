# Load aliases

if [ -f ~/.aliases ]; then
    source ~/.aliases
fi

# Prompt

#GREEN="$(tput setaf 2)"
#RESET="$(tput sgr0)"

#export PS1='${GREEN}(\j) \w : \u > ${RESET}'
export PS1='(\j) \w : \u > '