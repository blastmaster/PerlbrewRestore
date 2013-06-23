#! /usr/bin/zsh

function help()
{
    echo "PerlbrewRestore [src] [target]"
    echo "Install all Modules from src in perl version target"
    exit
}

declare -a output
output=($(perlbrew list | sed 's/^*\?\(.*\)/\1/'))
newest=${#output[@]}

for ((i = 0; i <= ${#output[@]}; i++)) do
    if  [[ $PERLBREW_PERL == ${output[i]} ]]; then
        current=$i
    fi
done

i=1
for version in ${output[@]}; do
    [[ ! -z $1 ]] && [[ $1 =~ "$version" ]] && src=$i
    [[ ! -z $2 ]] && [[ $2 =~ "$version" ]] && target=$i
    i=$(($i + 1))
done

tmpsrc=$(($current - 1))
src=${1:-${tmpsrc}}
[[ $src =~ "[0-9]+$" ]] && [[ ! -z ${output[$src]} ]] || help
target=${2:-${current}}
[[ $target =~ "[0-9]+$" ]]  && [[ ! -z ${output[$target]} ]] || help

echo -n "newest "
echo ${output[$newest]}
echo -n "source "
echo ${output[$src]}
echo -n "target "
echo ${output[$target]}

# perlbrew switch ${output[src]} > /dev/null
# perl -MExtUtils::Installed -E 'say for ExtUtils::Installed->new->modules' > /tmp/installed.list
# perlbrew switch ${output[$target]} > /dev/null

count=$(wc -l /tmp/installed.list | awk -F " " '{print $1}')
echo "Install $count Modules yet? [y/n]"
read x;
case $x in
    [yY]) echo "installing" cat /tmp/installed.list | cpanm --interactive ;;
    [nN]) echo "Nothing" ;;
    *) echo "invalid input Abort";;
esac
