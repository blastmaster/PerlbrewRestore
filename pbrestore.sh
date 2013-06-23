#! /usr/bin/zsh

function help()
{
    echo "PerlbrewRestore [src] [target]"
    echo "Install all Modules from src in perl version target\n"
    echo -n "src and target can be the index of the perlbrew list output "
    echo "or the name of the perl installation"
    exit
}

[[ $1 == '--help' ]] && help
declare -a output
echo $modfile
output=($(perlbrew list | sed 's/^*\?\(.*\)/\1/'))
newest=${#output[@]}

for ((i = 0; i <= ${#output[@]}; i++)) do
   [[ $PERLBREW_PERL == ${output[i]} ]] && current=$i
done

tmpsrc=$(($current - 1))
src=${1:-${tmpsrc}}
unset $tmpsrc
target=${2:-${current}}

i=1
for version in ${output[@]}; do
    [[ ! -z $1 ]] && [[ $1 =~ "$version" ]] && src=$i
    [[ ! -z $2 ]] && [[ $2 =~ "$version" ]] && target=$i
    i=$(($i + 1))
done

[[ $src =~ "[0-9]+$" ]] && [[ ! -z ${output[$src]} ]] || help
[[ $target =~ "[0-9]+$" ]]  && [[ ! -z ${output[$target]} ]] || help

echo -n "from "
echo -n "${output[$src]} -> "
echo -n "to "
echo ${output[$target]}

if [[ -e $modfile ]]; then
    rm $modfile
fi

perlbrew switch ${output[src]} > /dev/null
perl -MExtUtils::Installed -E 'say for ExtUtils::Installed->new->modules' > $modfile
perlbrew switch ${output[$target]} > /dev/null

count=$(wc -l $modfile | awk -F " " '{print $1}')
echo "Install $count Modules yet? [y/n]"
read x;
case $x in
    [yY]) echo "installing..." cat $modfile | cpanm --interactive ;;
    [nN]) echo "User Abort" ;;
    *) echo "invalid input Abort";;
esac
