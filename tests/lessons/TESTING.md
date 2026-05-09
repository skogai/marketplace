# lesson system testing

run the matcher directly from `plugins/dot-core`:

```bash
python hooks/lesson_matcher.py --mode prompt --text 'active memory plugin'
python hooks/lesson_matcher.py --mode tool --text 'git commit' --tool 'user-prompt-submit'
python hooks/lesson_matcher.py --mode prompt --text 'git active memory' --tool 'user-prompt-submit'
```

run the matcher tests and hook suite:

```bash
uvx pytest hooks/test_lesson_matcher.py -v
bats tests/*
```
