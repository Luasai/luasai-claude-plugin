# Account-list workflow

Use this state machine for multi-row Luasai enrichment. Preserve partial
success and keep each physical row independently traceable.

## 0. Preflight native capabilities

Confirm the required Luasai MCP tools and the provider-approved artifact
workflow before opening the workbook or retrieving organization data. Follow
the active client's native spreadsheet or file workflow; do not substitute an
unapproved library, connector, or local helper. A missing native file
capability is a clean preflight failure, not permission to downgrade the
workflow.

## 1. Inspect and freeze inputs

For each physical row, record:

- source sheet or table and physical row number;
- stable `input_id` such as `sheet-number:excel-row`;
- submitted organization name exactly as supplied;
- local context fields and their semantics;
- requested output fields and partner-selection criteria; and
- original output values, formulas, and formatting that must be preserved.

Duplicate names remain separate rows. They may share a candidate lookup only
when their names and typed hints are equivalent, but their `input_id` values,
decisions, relationship outcomes, and writeback states remain distinct.

## 2. Retrieve organization candidates

Start with `luasai_graph_organization_candidates` using:

- at most 25 physical rows per call;
- `retrieval_mode: fast`;
- `profile_detail: compact`; and
- only supported typed hints that are genuinely present in the row.

Represent a generic Country, Market, or territory as geography with
`relationship: market`. Use `headquarters` only when the source explicitly
says headquarters. Omit empty or invalid geography rather than manufacturing a
country code. Known domains, aliases, and organization types remain ranking
clues, not proof.

Each returned row has its own status. Retain successful rows and retry only
failed `input_id` values after a transport or upstream failure.

Keep at most two candidate calls in flight. Record each successful request in
the row ledger by exact `input_id`, submitted name, typed hints, retrieval mode,
profile detail, and cursor. Never reissue that same successful request. A
different mode, richer detail, or valid continuation cursor is a new request;
model uncertainty about a response already received is not.

Treat candidate calls as bounded waves. Before starting the next wave, reconcile
every returned `input_id` from the completed wave into client working state,
including its status, profiles, and continuation cursor. Confirm that the count
of retained row receipts equals the count submitted in that wave. A successful
response is not safely retained merely because it appeared earlier in the
conversation. If the client cannot preserve a completed response, stop with a
client-state failure while the gap is visible; do not continue and later turn
successful MCP rows into bulk response-capture failures or replay the request.

For every row without a defensible fast candidate, request semantic candidate
page one. Semantic calls contain at most five unresolved rows; five is a
per-call limit, not a workbook limit. Request rich detail, also at most five
rows per call, only when a truncated field prevents a decision.

Before adding a row to the semantic queue, run the mandatory strong-candidate
audit from `identity-and-source-boundaries.md` across all fast candidates. A
single fast candidate that passes a positive identity gate with no material
contradiction is a completed identity decision, not an ambiguous row. Do not
send it to semantic retrieval or later abstain merely because its name contains
ordinary corporate expansion terms or its organization roles are broader than
the input hint. Two or more distinct candidates that independently pass remain
ambiguous unless explicit row context and returned fields uniquely disambiguate
one; rank or score cannot break the tie. A shared parent-brand token or bare
brand alias does not make a geographic affiliate, sub-brand, product, or joint
venture independently defensible when its displayed name, description,
geography, or hierarchy identifies a different entity.

Maintain one accumulated profile per stable organization ID across fast and
semantic modes and all pages. Merge non-conflicting inspected evidence and all
occurrence paths for repeated IDs; do not count the same publicv2 organization
twice when testing whether multiple distinct candidates remain. If retained
copies materially conflict on name, domain, geography, hierarchy, or another
identity field, record the inconsistency and treat that candidate as unresolved
unless an explicit returned authoritative field reconciles the copies. Never
choose a copy because it is more complete. If that unresolved candidate is the
only profile to pass a positive gate, abstain and name the conflicting fields.

Page only when the current profiles make it plausible that the intended entity
is lower in the ranked window. Repeat the exact `input_id`, name, typed hints,
and returned cursor. When semantic page one contains no candidate with the
submitted name's distinctive tokens but says more candidates exist, inspect
page two before abstaining; noisy page-one ranking can hide an expanded name.
Stop once a defensible identity is selected. Continue beyond page two only
when the latest page introduces a related name, alias, domain, description, or
hierarchy clue. Do not drain unrelated pages merely because a cursor exists.

## 3. Decide and freeze identity

Apply the identity rules in `identity-and-source-boundaries.md`. Record:

- candidate pages and modes inspected;
- selected organization ID and name, or explicit abstention;
- strongest supporting fields;
- material contradictions checked;
- concise rationale; and
- whether another page or missing user evidence could change the decision.

For every proposed abstention, also record `strong_candidate_audit` entries for
all flagged returned profiles. Each entry includes candidate ID, inspected
mode/page and rank, positive field, and a concrete contradiction or resolution.
The audit must cover every returned candidate on every inspected page. A row
cannot be frozen as abstained while exactly one uniquely defensible flagged
candidate remains. When multiple distinct flagged candidates remain defensible
and the row context does not resolve them, abstain with their IDs and the
specific missing discriminator instead of choosing arbitrarily.

A fast miss is not a publicv2 coverage conclusion. Distinguish:

- retrieval exhausted without the intended entity;
- ambiguous candidates;
- material candidate contradiction;
- candidate-search failure; and
- adjudicated governed-data coverage gap.

Freeze one organization ID or abstention for every physical row before graph
search. Before freezing, perform the second-pass positive-evidence audit from
`identity-and-source-boundaries.md` across every proposed selection; this uses
the retained profiles and makes no new MCP call. Run the corresponding
pre-abstention audit across every proposed abstention in the same pass. Preserve
the inspected mode/page path for abstained rows in the audit output. Do not
silently revise identity because a later relationship result is more
commercially convenient.

## 4. Retrieve relationships

First scope `luasai_graph_revealed_relationships` to the selected subject
organization IDs when saved results may satisfy the request. Viewing saved
results uses no credits.

Then use `luasai_graph_search` with `account_input_refs`, preserving the exact
physical-row IDs. Apply only the user's criteria:

- a general account-to-reseller request uses `relationship_type:
  reseller_account`;
- a request such as “Snowflake partner” requires reseller-account
  relationships whose reseller is independently linked to the named software
  company, using the tool's published `required_reseller_isv_terms`; and
- a reseller-to-software-company question uses `relationship_type:
  reseller_isv` and its required `isv_terms`.

Do not infer a software partnership from an existing spreadsheet value, email,
company description, or reseller name. Follow relationship pagination when
later results could change the requested cell. Preserve whole-result per-row
counts so a current empty page is not mistaken for a relationship gap.

Partner cardinality belongs to the user, not the model. If the request states a
count, ranking rule, or selection criterion, apply it deterministically. If it
does not, deduplicate by relationship organization ID and write every
qualifying named relationship from the complete paginated result set in stable
server order. A singular column label or the word “significant” does not imply
“top three.” If the destination cell cannot safely hold the complete set, put
the full set in the requested audit/detail destination and make the summary
cell's truncation and total count explicit; never silently discard names.

For equivalent duplicate rows that select the same organization and use the
same criteria, apply the same partner-selection policy. Preserve their separate
reconciliation receipts.

## 5. Quote and reveal

Graph search is free and returns a server quote. Determine which relationship
keys are actually needed for the requested named output. Before the first paid
action, report the exact quote through the active client approval flow.

Call `luasai_graph_reveal` only for needed keys from the current quote. Use a
stable task-scoped idempotency key. Trust the server-returned charge, newly
revealed count, already-revealed count, and remaining balance; never estimate
them. Reopening an entitlement is not a new reveal.

If reveal is unavailable or not approved, retain the row as
`qualifying_relationship_unrevealed` rather than converting a masked preview
into a named partner.

## 6. Write and reread

Write only the requested output cells and any explicitly requested audit sheet.
Use the provider-native artifact workflow already approved for this task and
preserve source values, physical-row order, duplicate rows, sheet names,
formulas, validations, styles, and unrelated columns.

Every row must end with one identity status, one relationship status, one
writeback status, and a truthful reason for each blank. Keep these terminal
states distinct:

- identity abstained or unresolved;
- selected organization with no qualifying Luasai relationship;
- qualifying relationship present but unrevealed;
- MCP or reveal failure;
- value chosen but not written; and
- value written and reread successfully.

After saving, reopen the artifact and verify:

- row count and order;
- source columns and formulas;
- every requested output cell;
- every blank reason;
- formula-error scan; and
- reveal receipts against the server response and wallet delta.

Rendering is not visual inspection. Open every rendered sheet image with the
active client's native image-view capability and inspect it. A PDF page count,
file existence check, text extraction, or command exit code cannot support a claim
that the workbook was visually inspected. Treat clipping, overflow across row
or column boundaries, and collisions with other values as failed completion.
Repair the workbook, rerender every affected sheet, and open the repaired
images before reporting completion.

When a complete partner list cannot fit readably in the source layout, keep the
complete stable-order set in the audit or detail sheet and replace only the
source summary cell with the first three names followed by
`(+N more; see MCP Evaluation)`. This is an explicit presentation summary, not
a top-three result limit: counts, status, and the audit row must still describe
the complete qualifying set.

Report rows processed, selected, abstained, populated, explicit relationship
gaps, MCP failures, semantic follow-ups, candidate and relationship pagination,
credits charged and remaining, and saved-artifact reread status. Do not claim
ground-truth match accuracy without a separately adjudicated identity ledger.
