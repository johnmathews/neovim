-- Messages the smoke gate accepts. Every line that appears in :messages, stderr or
-- noice's history must be a recorded notify, an Nvim deprecation notice (judged by
-- its caller), or match an entry here. Anything else fails the run.
--
-- Entry: { match = "plain substring", reason = "why this is fine", nvim = "0.12" (optional) }
return {}
