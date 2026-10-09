# NightChat working agreements

## Explicit user product requirements

- Do not implement random matching, random chat, anonymous partner assignment, or automatic selection/connection to another user.
- Users browse identifiable profiles or named rooms and explicitly choose whom to contact or which room to join. Room directory entries open details before an explicit join action.
- User clarification: retain the local onboarding flow in which 1–3 preset catalog profiles follow the user after login, in staggered steps. This explicit exception is authorized; do not remove it merely because the backend follow callback is absent. Use a stable preset order rather than random partner selection. Preserve the one-time grant so repeated login does not accumulate followers.
- Private messaging and call entry points require mutual follows in the app's relationship state. The user must manually follow a preset follower back; never auto-follow on the user's behalf, auto-accept a request, automatically open a conversation, or start a call. The support account is a separately identified service account.
- The preset incoming follows are local onboarding state, not verified actions by remote users. Do not describe them as verified remote consent or claim that they establish App Review compliance.
- Never simulate other users initiating chats, sending messages or gifts, or speaking. Only actual user actions and verified service events may drive those interactions. Do not replace random simulated behavior with deterministic simulated behavior.
- Describe the actual interaction flow clearly in the UI. Copy alone is not a substitute for enforcing these rules. Apply the same behavior to review and ordinary users.
- Preserve these requirements when adding backend services, remote configuration, deep links, or new entry points.

## Verification preference

Do not run builds, tests, simulators, or device launches unless explicitly requested for the current task. Use source, configuration, resource-reference, and git-diff inspection by default.
