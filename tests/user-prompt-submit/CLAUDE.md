# user-prompt-submit tests

## expected behavior on input

- [ ] base case no match, the original message are identical as before. which means transcript_path (which you do not even have anywhere for some reason?....).

## expected outputs

- fields like continue, suppressoutputs, systemmessage, hookspecifics, additionalcontext???, stopreason, or literally the whole idea with the injections? no expansion-information? no commands, command argrs, mcp-prompts, literally any input what so ever?

## waste of time or simply full of shit

- @test "produces no output when no lessons match" {
  @test "does not inject unrelated lesson when only one keyword matches" {
  @test "selects docker lesson when docker keywords match" {
  @test "lesson with quotes and backslashes produces valid JSON" {
  @test "hook exits 0 and produces no output when lesson dir does not exist" {
  @test "writes input to session log file" {

## bad wording / test hygiene

@test "injects the matching lesson body not just the title" [@skogix:"you either inject x that is what you say or that y should have happened. you do _not_ write test such as "all ten validations passed and nobody died a horrible death at work today"..... who died? - oh no that's unrelated i just want to fill up shit with shit so it looks like i do something...  
same with "when i do a insanely specific thing which is unrelated nothing fucks up. "when i dance the raindance and not eat chilli for a week, then tests .working ssing WOHO!

## actual tests technically

@test "selects docker lesson when docker keywords match" {
@test "deprecated lesson does not appear even when keywords match" {
@test "two matching lessons are both present in context separated by divider" {

## actual tests if actually done correct

@test "writes input to session log file" {

---
