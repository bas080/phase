# Contribute

README and EXAMPLES are generated with markatzea


```bash bash
markatzea README.mz > README.md
npx markdown-toc -i ./README.md
```

```bash bash > ./EXAMPLES.md
echo '# Examples'

for script in ./example/*; do
  echo "## $script"
  echo

  echo '```bash'
  cat "$script"
  echo '```'

  echo '```'
  ./phase "$script" 2>&1
  echo "exit code: $?"
  echo '```'
done

```
