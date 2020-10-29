# Defined in /tmp/fish.tYqcCO/git-split-commit.fish @ line 2
function git-split-commit
  set -l cmd (set_color --bold cyan)
  set -l num (set_color --dim white)
  set -l re (set_color normal)
  echo $num"1.$re Start a rebase including the commit:"
  echo "        $cmd""git rebase -i \"\$COMMIT^\"$re"
  echo $num"2.$re Mark the commit you want to rebase as $cmd""edit$re"
  echo $num"3.$re When you get to that commit:"
  echo "   $num""3.1.$re Reset state to the previous commit:"
  echo "        $cmd""git reset \"HEAD^\"$re"
  echo "   $num""3.2.$re Add and commit changes with $cmd""git add$re and $cmd""git commit$re"
  echo $num"4.$re Finish splitting the commit:"
  echo "        $cmd""git rebase --continue$re"
  echo
  echo "For more information, see:"
  echo (set_color --underline)"https://embeddedartistry.com/blog/2018/02/19/code-cleanup-splitting-up-git-commits-in-the-middle-of-a-branch/$re"
end
