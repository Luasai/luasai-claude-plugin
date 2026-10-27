# Account-list identity-stage workflow

> **Operator-only.** The normal default identity load is
> `bounded-account-list-workflow.md`. Read this module only for an explicit
> lower-level `luasai_graph_organization_candidates` investigation.

Use this state machine for the identity stage of multi-row Luasai enrichment,
whether the rows come from an artifact or a chat-supplied list. When a source
artifact exists, preserve every physical source row, tab, and source value;
deduplicate lookup effort only. Keep each physical row independently traceable
from input through to a frozen identity decision and its client decision
receipt. After the identity stage freezes, the requested relationship, reveal,
and writeback stages live in `relationship-writeback-stage.md`; an identity-only
lookup stops here.

## Normal bounded workflow (the supported default)

This is the supported normal workflow. It prepares bounded choices in ONE call
and then selects among them. Use it unless you are deliberately running the
explicit operator investigation path in section 2 below.

1. **Read the source once.** Preserve every tab, cell provenance, source value,
   and physical ID. Deduplicate identical lookup effort, never physical rows.
2. **Extract only the literal supplied clues.** Put the row's own known domains
   in `known_domains`, its own aliases in `aliases`, and only a genuinely present
   geography clue in `geography` (use `relationship: headquarters` only when
   the source explicitly says headquarters; otherwise leave the default
   `market`). Keep every clue attached to the account it actually describes,
   and preserve the submitted name exactly.
3. **Ground a name variant when the cell is not directly searchable.** When a
   source cell is a compound value or is longer than the bounded 2–120-character
   retrieval query, send the primary name as a source-grounded
   `alternate_query` with basis `name_variant`, keeping the original `name` and
   `input_id` on the row.
4. **Submit at most 20 physical rows per call** to
   `luasai_graph_prepare_organization_choices`. Preflight it once per run; if it
   is missing, fail cleanly at preflight and do not silently fall back into an
   open-ended candidate-research loop.
5. **Select in one batch.** Select exactly one returned `organization_id` or an
   abstention per physical row, using your own row facts and the run's source
   context. The server's retrieval ordering is not confidence: a
   `trigram_fill` or semantic match is a retrieval lead only. Do not run web or
   independent company research, invent alternative companies, or fall back to
   a family/parent lookup.
6. **Permit at most one targeted identity-detail round.** When a decision
   genuinely needs one omitted identity fact on a returned candidate, spend at
   most one read through the existing
   `luasai_graph_organization_identity_evidence` capability already returned on
   that candidate. Never pre-fetch it for every missing optional field or for
   rows you can already decide.
7. **Keep execution-incomplete separate.** A local input condition, a transport
   or upstream failure, or the shared deadline leaves the row
   execution-incomplete: it is never a No match by default and must be retried.
   The preparation receipt's `preparation_state` is `complete` only when every
   physical row is `ready`; a produced envelope whose rows all failed is still
   `incomplete`.
8. **Retrieve requested relationships through the existing path.** Once
   identity is frozen, use `luasai_graph_search` with `account_input_refs` and
   `luasai_graph_revealed_relationships` exactly as
   `relationship-writeback-stage.md` describes, preserving the user's criteria,
   pagination, tenant permissions, reveal approvals, and entitlement checks.
   Do not infer partner names from identity facts.
9. **Write and reread.** Write the requested output cells in batches, then
   reopen the artifact and verify the persisted values and hyperlinks. A
   successful write call is not delivery completion.

The preparation call returns a bounded shortlist only: at most three candidates
per executed stage, so at most six returned appearances per row and potentially
fewer distinct IDs. It is never a full-corpus search and never proves an
absence. A supplied parent, group, or other column value stays its own ordinary
lookup — the same physical rows and typed hints, its own `input_id` — and is
never a substitute for the company cell. The initial bulk lane covers its published fuzzy and prefix arms; semantic
recovery preserves those initial choices. Neither lane covers operating-name
retrieval. A completed bounded No match
means no defensible identity in the returned choices, not global absence. Keep
that limitation in private diagnostics; do not automatically start the operator
path or web research. Candidate coverage is an accuracy gate in the benchmark.
Schema-invalid input rejects the entire call before lookup. Correct or separate
invalid rows while retaining their original source values; this differs from
accepted rows that return local execution conditions or upstream errors.

## 0. Preflight native capabilities

Preflight only the capabilities the operation needs.

The identity stage needs `luasai_graph_prepare_organization_choices`, the
supported normal bounded-preparation operation. Preflight it once per run; when
it is missing, the identity work stays incomplete and never silently degrades
into an open-ended candidate research loop. The lower-level
`luasai_graph_organization_candidates` tool is retained for an explicit operator
investigation (section 2) and is not the normal Guide's research loop. The
optional candidate identity-detail read is used only when the active client
actually advertises it and a row genuinely needs it, so its absence is never a
reason to downgrade or to invent an identity.

A chat-only lookup answered from a pasted list needs no file or spreadsheet
capability. Opening, processing, or writing a file or spreadsheet — including
identity-only sheet work — requires the provider's approved native artifact
workflow. Follow the active client's native spreadsheet or file workflow; do
not substitute an unapproved library, connector, or local helper.

The identity stage never needs `luasai_graph_search`,
`luasai_graph_revealed_relationships`, or `luasai_graph_reveal`. Relationship
retrieval, saved-relationship reads, and reveal are separate operations: when
the user asks for partner relationships, and only then, preflight the
relationship tools listed in `relationship-writeback-stage.md`, with saved
reads and paid reveals under their existing conditions and approvals. Writing
identity results only needs the approved artifact workflow and none of those
relationship tools.

A missing capability an operation actually needs is a clean preflight failure,
not permission to downgrade the workflow.

## 1. Inspect and freeze inputs

For each physical row, record:

- source sheet or table and physical row number;
- stable `input_id` such as `sheet-number:excel-row`;
- submitted organization name exactly as supplied, kept separately from any
  derived retrieval terms;
- local context fields and their semantics;
- requested output fields and partner-selection criteria; and
- original output values, formulas, hyperlinks, and formatting that must be
  preserved.

Preserve every tab and every physical row, including duplicates. Duplicate names
remain separate rows. They may share a candidate lookup only when their names
and typed hints are equivalent, but their `input_id` values, decisions,
relationship outcomes, and writeback states remain distinct.

Preserve the entire supplied cell as source identity, including annotations,
named entities, domains, and qualifiers. Derived lookup strings change only
retrieval, under the existing useful bounded recovery rules. Apply the source
context and domain-hint boundaries in `identity-and-source-boundaries.md`: raw
annotations and subsidiary-domain lists are not platform ownership or requested
primary-domain facts; explicitly attributed specific-company domain hints stay
client-local retrieval leads.

Resolve the account names the user supplies. When one row carries two supplied
account names in different columns — for example a company cell and a separate
parent, group, or brand cell — each cell is its own ordinary account lookup
through the same candidate tool. Give every requested cell its own distinct
stable `input_id` (for example `sheet:excel-row:company` and
`sheet:excel-row:group`), keep its own submitted name, decision, and result
separate, and never silently replace an unmatched company cell with a matched
group cell. A group or parent cell value is a user input, not a verified
corporate-relationship fact and not a special parent resolver mode. A supplied
group name is only its own exact-name lookup: if it does not match, that cell
ends as `No match` — it is never promoted to its own further parent, and the
group column carries no family-relationship proof.
Keep retrieval hints attached to the account they describe. A company cell's
website, aliases, industry, or headquarters must not be copied onto a separate
group-cell lookup unless the source explicitly describes that group account.

## 2. Explicit operator path — retrieve organization candidates

This section is the explicit operator investigation path and is NOT the normal
workflow. It walks the lower-level `luasai_graph_organization_candidates` tool:
an optional whole-sheet bulk first pass, then per-row fast and batched semantic
recovery. Use it only when an operator deliberately needs that hands-on
inspection. The normal bounded workflow above submits each physical row once to
`luasai_graph_prepare_organization_choices`, which runs the same bounded
retrieval and recovery internally.

Choose the retrieval mode once from what the connected
`luasai_graph_organization_candidates` input schema actually advertises, and
keep the caller's settled identity decisions — a row already frozen from a
returned shortlist is never re-searched:

- when the advertised input schema offers the `bulk` value for `retrieval_mode`,
  start with the whole-sheet bulk-first pass in "Bulk discovery mode" below —
  compact, `retrieval_mode: bulk`, with the explicit `candidates_per_name: 3`;
  or
- otherwise use the incumbent fast first pass shown under "Legacy fast first
  pass" below; and
- in every mode send only supported typed hints that are genuinely present in
  the row.

Rows that stay unresolved after the bulk shortlist enter the existing bounded
recovery below in this order: the incumbent `fast` mode for the rows whose
decision genuinely needs the operating-name or fuzzy coverage the bulk lane
lacks, then semantic recovery. When the advertised input schema also offers the
`bulk_semantic` value for `retrieval_mode`, batch that semantic recovery into
"Bulk semantic recovery mode" below — one compact request of at most 20
unresolved rows at `candidates_per_name: 3` — instead of the serial five-row
`semantic` calls. When it does not, keep the incumbent serial `semantic`
recovery on this page.

The per-call row cap, the candidate-slot budget, the per-mode page limits and
cursors, and the finite per-row recovery budget below govern the legacy fast
first pass, the bulk rows that stay unresolved after the bulk shortlist, and the
batched semantic recovery. They are never an automatic full fast sweep over
every row before the bulk pass.

Legacy fast first pass:

- at most 25 physical rows per call;
- `retrieval_mode: fast`;
- `profile_detail: compact`; and
- only supported typed hints that are genuinely present in the row.

Full explanations are the default: the candidate response carries the static
`candidate_semantics` block. A caller may send the optional
`include_semantics: false` input to omit that static block, but only after both
identity references in stage 1 are already loaded and only when the active
candidate tool schema advertises `include_semantics`. When the advertised schema
does not include it, omit the flag rather than sending a probe request; the flag
changes no profile, result, hint, status, error, cursor, window, or truncation,
and it never carries into a token or cursor.

Represent a generic Country, Market, or territory as geography with
`relationship: market`. Use `headquarters` only when the source explicitly
says headquarters. Omit empty or invalid geography rather than manufacturing a
country code. Known domains, aliases, and organization types remain ranking
clues, not proof.

A query that changes the retrieval string — a bounded name variant of the
submitted entity, or, only when the client has explicitly declared a broader
related-account intent, a related parent, family, brand, or network account — is
sent as that row's `alternate_query` with its declared `basis` (`name_variant`
or `family_network`). The `family_network` basis is only for a broader search
beyond the named account that the user expressly asked for — for example,
group-wide opportunity discovery beside a matched subsidiary — and is never an
automatic fallback for a supplied name that did not match, and never implied by
a group column alone. Keep the submitted `name` and `input_id` on the
row unchanged: the tool searches the alternate string but returns the original
name as `submitted_name` and echoes the alternate query and its basis back. The
alternate string is a retrieval lead only; it never claims identity and is
never match evidence, and a source parent, group, or contract cell can justify
the query but can never establish the match. A related-account query never
replaces a matched subsidiary identity and never moves that account's partner
relationships onto the subsidiary.

Keep the submitted source name exactly as the source row supplies it, even when
a cell is far longer than an ordinary company name. The tool preserves it as
`submitted_name`, but the effective upstream retrieval query stays bounded to
2–120 characters: a longer cell is never silently truncated and no prefix of it
is searched. Send the grounded bounded variant — for example the primary name
of a compound source cell — as that row's `alternate_query` with basis
`name_variant`, keeping the original `name` and `input_id` on the row. A row
whose returned error code is `source_name_too_long` is incomplete until it is
reissued with such a bounded grounded variant, or completed through the locally
unusable input path in section 3. A blank or one-character source name is never
itself sent to search: check every usable context or alternate hint first, and
when one supports a grounded 2–120-character variant, send that variant as the
row's `alternate_query` (basis `name_variant` for a variant of the submitted
entity, or `family_network` for a related account). Only when no grounded
bounded variant exists does the tool report error code `insufficient_input` with
`retryable: false` — its `retry_guidance` forbids an automatic identical retry,
not a newly grounded alternate — and only then does the row complete as
`No match` with the existing `invalid_input` reason for a locally unusable input
row; the tool-level `insufficient_input` error and the receipt-level
`invalid_input` reason describe that same insufficient-input condition. Either
way the source value and the physical row are preserved, no candidate request is
recorded as a zero-hit search, and every sibling row in the same call still
completes.

Each returned row has its own status. Retain successful rows and retry only
failed `input_id` values after a transport or upstream failure.

Keep at most two candidate calls in flight — a client-side transport bound,
distinct from the resolver's own upstream search concurrency. Record each
successful request in the row ledger by exact `input_id`, submitted name, typed
hints, retrieval mode, profile detail, and cursor. Never reissue that same
successful request. A different mode, richer detail, or valid continuation
cursor is a new request; model uncertainty about a response already received is
not.

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
per-call limit, not a workbook limit. When the connected schema also advertises
the `bulk_semantic` value for `retrieval_mode`, batch those semantic requests
into the "Bulk semantic recovery mode" below — one compact request of at most 20
unresolved rows at `candidates_per_name: 3` — instead of serial five-row calls.
Keep the fast first pass at
`candidates_per_name: 5`. When the connected tool's advertised input schema
allows `candidates_per_name: 20`, use that larger compact page for semantic
recovery; if the advertised maximum is five or unavailable, keep five. Never
send an unsupported page size merely because this Skill is newer than the
connected server. Request rich detail, also at most five rows and at most five
candidates per row per call, only when a truncated field prevents a decision.

A compact call requests at most 125 candidate slots in total:
`row count × candidates_per_name ≤ 125`. A semantic call with five rows and
20 candidates uses 100 slots; a fast call with 25 rows and five candidates
uses 125. Shrink the batch when choosing a larger page. Choose the size before
issuing a page; a larger size never justifies replaying a successful page.
If changing size for a continuation, retain the issued cursor and exact row,
query, context and retrieval mode. Record the chosen size in the request ledger.

Before adding a row to the semantic queue, run the mandatory candidate audit
from `identity-and-source-boundaries.md` across all fast candidates. A single
fast candidate that passes a positive identity gate with no material
contradiction is a completed identity decision, not an ambiguous row. Do not
send it to semantic retrieval or later return a no-match merely because its
name contains ordinary corporate expansion terms or its organization roles are
broader than the input hint. Two or more distinct candidates that independently
pass remain ambiguous unless the source-context comparison in
`identity-and-source-boundaries.md` or other explicit row context and returned
fields uniquely disambiguate one; rank or score cannot break the tie. A shared
parent-brand token or bare brand alias does not make a geographic affiliate,
sub-brand, product, or joint venture independently defensible when its displayed
name, description, geography, or hierarchy identifies a different entity.

The exact positive gates (including the domain-shaped commercial-name, bounded
mechanical mixed-case abbreviation, and own brand-bearing primary-domain
lanes, plus the domain-shaped lane's own former commercial-name bridge and the
display-root-linked narrower-rival clarification), the commercial eligibility
definition, the discovery-only scope of the commercial-selection allowance, and
the supplied country/market tie breaker live in
`identity-and-source-boundaries.md`; apply them here rather than restating them,
and do not widen formal CRM, legal-entity, or strict-ingestion resolution.

A candidate whose `retrieval.lexical_match_kind` is the low-authority fuzzy
`trigram_fill` is a retrieval lead, not a positive gate: it enters the audit only
when its own returned name, legal name, alias, domain, description, or hierarchy
evidence passes a positive identity gate. Fuzzy similarity cannot promote it to
a match, cannot turn an unresolved row into a completed `No match`, and never
demotes or replaces a matched exact subsidiary.

A `primary_domain` or `verified_domain` matched field is an equality of a stored
domain value, not identity. `primary_domain` is the account's actual primary
domain; `verified_domain` is a stored verified domain claim on the same public
canonical account, on the primary domain or on a different one. A caller-supplied
known-domain or known-alias hint may contribute a bounded candidate lead from the
stored value it names, but a supplied hint match is never source identity or a
family/network proof, and a domain shared by more than one organization stays a
separate lead for each.

A domain-shaped candidate query keeps the exact-domain lane's existing
precedence: a non-empty exact-domain result is the seed set and the supplied
hints only re-rank those candidates, without adding a candidate from another
hint owner, while an empty exact-domain lane falls through to the hinted fast
path where those hints contribute bounded seeds.

Maintain one accumulated candidate and one assessment per stable organization ID
for one physical row — across fast and semantic modes, every candidate page, and
every original, derived, or alternate query that row sends inside the same
existing budget. Merge non-conflicting inspected evidence and preserve all
occurrence paths; do not count the same publicv2 organization twice when testing
whether multiple distinct candidates remain, and inspect every returned copy for
new or conflicting identity facts. When a copy's facts are unchanged, reuse that
candidate's prior assessment instead of repeating the full reasoning or writing
a duplicate `strong_candidate_audit` entry; when they are new, changed, or
conflicting, reassess that candidate and the whole accumulated pool's uniqueness
and contradictions, because a newly eligible distinct ID can invalidate an
earlier provisional selection. Never cache a selection irrevocably, skip an
inspection, suppress a conflict, prefer the more complete copy, or reuse an
assessment across physical rows or source contexts, and the pure retrieval
deduplication below is unchanged. If retained copies materially conflict on
name, domain, geography, hierarchy, or another identity field, record the
inconsistency and treat that candidate as unresolved unless an explicit returned
authoritative field reconciles the copies, and if that unresolved candidate is
the only profile to pass a positive gate, record the conflicting fields and
continue into bounded recovery.

Page only when the current profiles make it plausible that the intended entity
is lower in the ranked window. Repeat the exact `input_id`, name, typed hints,
and returned cursor. When a legacy five-candidate semantic page one contains no candidate with the
submitted name's distinctive tokens but says more candidates exist, inspect
page two before concluding; noisy page-one ranking can hide an expanded name.
With a fixed candidate pool, a 20-candidate compact first page covers at least
those two five-candidate pages for the same query and context. This does not
claim unchanged coverage of the earlier page-dependent ranking. Audit every
returned candidate, but continue it only when the returned
facts leave a plausible requested identity lower in the window; a larger page
never makes an unresolved competing match disappear. Never manufacture a
second page just to satisfy a page-count target after that wider coverage.
Stop at the finite budget's page limit — at most two pages per retrieval mode
per query — and do not drain later pages merely because a cursor exists.
A derived query does not reset the row budget. Derived queries consume the
shared three-derived-query allowance, while each
permitted query retains its two-pages-per-mode cap.

### Bulk discovery mode (bulk-first only when the connected tool advertises it)

When the connected `luasai_graph_organization_candidates` input schema it is
actually talking to advertises the `bulk` value for `retrieval_mode`, run the
column-preserving bulk-first pass below. When the advertised enum does not
include `bulk`, keep the incumbent fast workflow on this page unchanged and
never send a `retrieval_mode` the server does not advertise.

Preflight the bulk capability once per run, together with the other stage-0
capabilities; do not re-probe it per wave or per row.

A bulk call carries `retrieval_mode: bulk` with `profile_detail: compact` only.
One bulk call carries between 1 and 1000 physical rows, and the request's
`row_count × candidates_per_name` must stay at or below 3000 candidate slots.
Set `candidates_per_name` to the explicit value 3 for the bulk pass; do not
inherit a default. When a run has more than 1000 physical rows, or more than
3000 candidate slots at three candidates per row, pre-chunk into multiple bulk
calls before the first request so no call crosses either bound. Also budget the
serialized UTF-8 request size: the MCP HTTP ingress independently has a 1 MiB
body limit. Keep the tool arguments below 900 KiB to leave room for the client
RPC envelope; split oversized batches while preserving every physical row and
source column. This differs from the downstream Data Foundation parser, which
limits the raw serialized string to 1 MiB of UTF-16 units. A transport-size
refusal is an execution failure, never an identity absence. Every bulk page
is one POST: the server inspects name- and alias-rival candidates across its
known 50-candidate window per row before it clips the row to the returned
shortlist. After that guard, the backend and MCP bound individual profile fields
for transport, declaring shortened or omitted fields in the returned
`truncated_fields`. Canonical IDs and the effective query remain exact; oversized
domain and alias items are omitted whole. A shortened name is partial display
text, not the exact stored identity fact. Fetch detail only when the decision
depends on a shortened or omitted fact; do not fetch every flagged profile
automatically. The client never widens that window, and a clipped or partial
response never claims completeness.

Preflight and preserve the source exactly as section 1 requires: every physical
row across every tab and every preserved column keeps its own stable `input_id`
and submitted name, before any chunking. Chunking is a transport detail only; it
never merges, drops, or reassigns a physical row or its `input_id`.

Reconcile every bulk call on return: map each returned `input_id` to its status
and candidates, and when a call reports a retriable failure, retry only the
failed `input_id` values, never the whole successful call.

Process the bulk shortlist's returned facts and positive gates first. A strong,
valid returned identity may decide a row under the existing gates without paging
the full safety window and without a mandatory identity-detail read. Only rows
that stay unresolved after that first pass enter the existing bounded recovery —
the incumbent fast pass on this page, then semantic recovery, then the optional
identity-detail read on genuine ambiguity or a missing needed fact — before any
row may complete as `No match`. Do not run an automatic full-row fast sweep over
the whole list: fast recovery is a bounded, per-row step for genuinely
unresolved rows only.

A bulk response that is empty, partial, or blocked is never an absence and never
justifies a `No match`. Bulk coverage is explicitly incomplete. The returned
`candidate_support.status` of `candidate_proposal` or `recovery_required`, with
`requires_caller_decision: true`, means the row still needs the caller's own
context-matched decision under the existing identity gates. The server guard
does not replace user-context matching and never authorizes an absence selection.

The bulk response object carries `object_version:
luasai-graph-organization-candidates-bulk-v1`. Bulk has no continuation cursor,
no rich-detail mode, and no `family_network` alternate: the only alternate-query
basis a bulk request may use is `name_variant`, the raw source name is preserved
up to 500 characters, and the effective retrieval query stays bounded to 2–120
characters with no truncation of the source value.

### Bulk semantic recovery mode (only when the connected tool advertises it)

When the connected `luasai_graph_organization_candidates` input schema it is
actually talking to advertises the `bulk_semantic` value for `retrieval_mode`,
use it as the batched semantic recovery lane for the rows that stay unresolved
after the bulk shortlist and the bounded fast pass. It replaces the incumbent
serial five-row `semantic` recovery for those rows with ONE compact request of at
most 20 locally valid physical rows. When the advertised enum does not include
`bulk_semantic`, keep the incumbent serial `semantic` recovery on this page and
never send a `retrieval_mode` the server does not advertise.

Preflight it once per run together with the bulk capability; do not re-probe it
per wave or per row. A `bulk_semantic` call carries `profile_detail: compact`
only, between 1 and 20 physical rows, and its `row_count × candidates_per_name`
stays inside the same 3000 candidate-slot bulk budget. Set `candidates_per_name`
to the explicit value 3 for this lane; do not inherit a default. Keep the
whole-sheet bulk-first pass at `candidates_per_name: 3` and this recovery lane
at `candidates_per_name: 3`; the incumbent fast first pass keeps its own
`candidates_per_name: 5`, and neither bulk lane changes the default or the
fast/semantic page budget.

Coverage is deliberately partial and must be described precisely. Relative to
the v1 `bulk` lane, `bulk_semantic` additionally executes the semantic
lexical/vector/hybrid arms and, only for a row whose OWN typed clues supplied
them, the domain and alias hint-seed arms. It still does NOT execute the
operating-name projection or the fuzzy similar/prefix coverage, so an empty or
partial `bulk_semantic` window is never by itself an exhaustive absence and
never on its own selects a `No match`. The server's own coverage receipt already
enumerates the uncovered arms, so do not invent additional arm names. Like
`bulk`, the response is a single bounded compact pass with no continuation
cursor, no rich-detail mode, and a `name_variant`-only alternate query; the
returned shortlist is a bounded retrieval lead and not an absence proof. A
`bulk_semantic` row still completes only through the existing finite per-row
recovery and decisive-ambiguity decision, exactly like every other mode.

The lane hard-gates before the search POST: it requires the request's explicit
principal binding, a strictly positive discovery-retrieval advertisement, and a
confirmed v2 identity-evidence producer, and it re-checks v2 before issuing any
token. An authenticated discovery-retrieval readiness advertisement may be sent
first, before those gates pass; the gates themselves guard the search POST. A
missing method, a non-positive or malformed advertisement, a withdrawn v2
producer, a transport failure, a malformed, foreign, or incoherent response, or
another whole-batch refusal is the generic retryable
`candidate_search_unavailable` execution failure: it fails every attempted row
of that call, is never a silent lexical downgrade, never a legacy-mode fallback,
never a partial window published as absence, and never an identity `No match` —
the failed work stays incomplete to retry. Retry only the failed batch's own
work; do not repeat a whole successful worksheet because one batch failed. The
top-level response carries the `identity_evidence_availability` receipt only
when genuine explicit-v2 tokens were actually issued for returned usable
candidates (status `issued`); an empty successful window, a failed or declined
batch, or a v2 withdrawal omits that response receipt entirely rather than
inventing a "no token" status, an unavailable claim, or a legacy v1 fallback.
Each returned usable candidate carries its own identity-evidence token.

### Bounded recovery and query variants

Rows that remain unresolved after the fast pass use a finite per-row recovery
budget. This is an initial workflow policy derived from the existing API limits,
not a measured optimum. Each physical row gets:

- the original query plus at most three derived queries total, and one of those
  derived queries is reserved for a user-requested broader parent, family, or
  network search when one was expressly asked for;
- at most two pages per retrieval mode per query (fast page one and two,
  semantic page one and two);
- at most two rich-detail requests; and
- at most two retries of a failed attempt.

Separately scoped broader discovery for a matched subsidiary counts against the
same per-row budget; it does not open a second budget.

One physical row's legacy rich-detail requests and its optional identity-detail
reads share the same two-read allowance: the rich-detail budget and the identity
read are the same budget, each tool call counts as one read including a
continuation page, and a derived query does not reset it. That is the client's
own ledger, not a server-side global quota. The identity read also shares the
same at-most-two-calls-in-flight client transport bound as candidate calls; it
never opens a second budget or a second concurrency allowance.

The per-tool call caps are MCP call limits, not the recovery budget: a fast call
carries at most 25 rows and a semantic or rich call at most five rows. Compact
pages may request up to the connected server's advertised maximum of 20
candidates per row within the 125-slot call budget; rich pages remain at most
five candidates per row. The default and older-server page size stays five.
The two explicit bulk lanes have their own call caps rather than the fast or
semantic per-call cap: a `bulk` call carries between 1 and 1000 rows at up to
3000 candidate slots, and a `bulk_semantic` call carries between 1 and 20 rows
inside that same 3000-slot bulk budget; neither bulk lane widens the 125-slot
fast/semantic budget or the per-row recovery budget.
Keep at most two candidate calls in flight as a client transport bound; that is separate
from the resolver's own upstream search concurrency, which the client does not
control or raise. Each candidate query also traverses at most the server's
50-candidate safety window per row, and the client cannot widen it. Do not
widen the budget by raising any of these bounds.

Recovery may add bounded query variants for a row: spacing and punctuation
variants; ordinary legal suffixes; verified aliases; trading or former names;
and the primary name of a compound source cell. A compound legal name such as
`Banco Bilbao Vizcaya Argentaria, S.A. (BBVA)` is retrieved as its full original
name plus, when helpful, the parenthesized acronym as a separate clue. The
acronym never replaces or corrupts the original submitted name, and the
original name is preserved separately from derived retrieval terms. A shortened
initials or acronym form is a retrieval clue only, never the source identity, so
it does not replace the full cell and a merely string-equal stored result does
not by itself resolve the row: retain and evaluate the whole supplied cell —
annotations, named entities, domains, and qualifiers — keep an inspected
plausible same-core-brand or same-initialism rival in the audit even when it
lacks the shortened bare alias or does not independently pass an ordinary
exact-name or alias gate, and resolve only on coherent full-source and
own-profile support under `identity-and-source-boundaries.md`. An exact own short
brand with no unresolved plausible rival may still pass, no blanket
source-acronym expansion is required, and this adds no new exact-alias
precedence. Attempt a variant, an additional page, or a read only when it could plausibly change this
row's decision; once a defensible identity or an established ambiguity exists,
stop. Only ordinary legal suffixes are removed; institutional words such as
`Institute`, `Foundation`, or `Association` are not ordinary legal suffixes and
are never added to a generic strip list. Assess whether they distinguish a
different entity using the returned facts; do not assume they are disposable
or always distinctive. A meaningful kind or modifier conflict still blocks,
while an existing grounded commercial brand or trading continuity can still
identify the caller's own requested account without a literal qualifier alias.

Send each derived variant as that row's `alternate_query` with its `basis`:
variants of the submitted entity use `name_variant`, and a user-requested
broader related-account search uses `family_network` — the same basis
carries the separate broader opportunity search described in
`relationship-writeback-stage.md`, because the basis describes which
related-account discovery the string serves, not whether the subsidiary
already matched. The `family_network` basis is only for a
broader search the user expressly asked for; it is never an automatic fallback
for a supplied name that did not match. One alternate query per row per call,
and each keeps the original `name` and `input_id` on the row. The declared basis
is query provenance, not evidence: a `family_network` query says only that the
client is looking for a related account, and the candidate must still be
selected from the returned evidence under the fallback connection rule in
section 3. A related-account query never replaces a matched subsidiary identity
and never moves that account's partner relationships onto the subsidiary.

A cursor belongs to the exact query it was issued for. Repeat the same
`input_id`, name, hints, and alternate query with it, because changing the
alternate string, its basis, the hints, or the retrieval mode invalidates the
cursor and restarts that row at page one. A cursor is opaque and the client
never interprets its version. A cursor minted by a pre-fix server revision
(continuation version 1 or 2) is refused per row as `candidate_cursor_invalid`
before any lookup, because its older ranking offset cannot continue into the
corrected fixed window; restart only the unresolved affected row without the
cursor, keeping the candidate copies, contradictions, and identity decisions
already established for this row and all other rows. This is an intentional cursor compatibility
migration, not a malformed cursor and not a per-row No match. That restart opens
no second budget and replays no already-paid lookup: it consumes the same
per-row page, query, and derived-query allowance, and if the migration restart
cannot finish inside that budget the row stays incomplete and is retried later,
never a No match. Already-resolved rows are not re-searched or re-charged.

Pure lookup deduplication is allowed: rows whose effective search string, typed
hints, retrieval mode, and page match may share retrieval, and the declared
basis does not force a separate lookup because it never changes the request.
Every physical `input_id` still keeps its own echoed provenance, cursor,
decision, recovery record, and writeback. Every zero-hit physical row keeps an
explicit recovery record — including one that ends `Matched` after recovery —
with the attempted variants, the evidence checks performed, the fallback
attempts or a written reason they were inapplicable, and the final execution and
outcome state. A row with no recovery record is not complete.

Recovery ends when a defensible identity is selected or the per-row budget is
exhausted with only irrelevant candidates. A budget exhausted with only
irrelevant candidates is a completed `No match` with an insufficient-evidence
reason and a recovery record. A retrieval, transport, authorization, or
client-state failure is not a no-match: it leaves the row incomplete — and the
run incomplete — until the failed work is retried, while successful rows are
retained.

### Optional identity-detail read

When the active client advertises `luasai_graph_organization_identity_evidence`
and one candidate's identity is genuinely unresolved, or a needed identity fact
is still omitted from the returned profile, you may read that one candidate's
omitted public identity evidence. Pass back only the `identity_evidence_token`
exactly as returned on that candidate row: the tool accepts no arbitrary
organization id, query, offset, or page parameter, because the token pins one
organization and the requesting principal, tenant, and authentication type,
expires within ten minutes, cannot be refreshed, and can be replayed only within
its lifetime.

Use the identity read only for that unresolved or omitted-fact decision. Never
pre-fetch evidence for rows you can already decide, never page or offset it
indiscriminately, and never treat a token as an organization identifier to look
up by some other route. Every read re-checks fresh candidate eligibility, so a
rejected token, an unavailable, changed, or version-mismatched read, a missing
or stale record, or a transport failure is a failed or incomplete execution,
never a completed `No match`. A needed identity read that stays unresolved
leaves the row incomplete rather than a completed outcome, and it never becomes a
no-match by default. Follow the tool's returned `error.code`, `error.retryable`,
and `error.message`. Do not repeat a non-retryable read unchanged. An
`identity_evidence_not_found` error is not repeated unchanged and is not repaired
by minting another token for the same candidate — it means the current read for
that candidate is unavailable (it proves neither permanent identity
ineligibility nor an invalid signed token). A version-mismatch read (a
mixed-revision rollout or a serving misconfiguration) comes back as a retryable
execution-unavailable error with `error.retryable: true`, never a permanent
account decision: retry it inside the same two-read allowance, though the retry
can still fail while the serving fleet stays mismatched. The already-issued
token always requests its exact signed version and is never downgraded.
Restarting from the candidate page re-checks the producer's advertised support
and re-mints accordingly — it does not guarantee that every serving revision is
compatible. A `identity_evidence_version_unavailable` error is a bounded receipt
that does not match the requested version and is not repeated unchanged. Every
other error follows its own returned code,
retryable flag, and message: a retryable failure may be retried, and a
non-retryable change or expired-token error whose message tells the client to
restart from the candidate page may obtain a fresh candidate and token — all
inside the same two-read allowance, query budget, and failed-attempt retries,
with no extra budget. The caller never sends an evidence version to the MCP tool
(the candidate capability pins it) and never probes for an unadvertised
input. Keep every decision and any remaining permitted recovery that the other
returned candidates and facts independently establish within the same per-row
budget; a supplemental read failure is not by itself a reason to discard such a
decision, and it is never a reason to keep an identity the returned facts do not
independently establish. Prefer a decision you can make from the returned
candidates; the read is a bounded follow-on for one candidate, not a second
search surface. After applying the source-context comparison in
`identity-and-source-boundaries.md`, decide from the returned candidates first:
if they already establish two or more positively eligible commercial accounts,
and the actual submitted context cannot distinguish them, complete the row as
an ambiguity `No match` before spending this read and name the actual missing
discriminator privately — an arbitrary ambiguity label is never substituted,
and a read cannot invent client intent. A rival's missing or unknown own
locating geography that blocks the country comparison is not client intent but
a genuinely missing candidate fact, so the bounded recovery or own-identity
read applies before the ambiguity closes, and a read that still leaves it
unknown may still complete as an ambiguity `No match`. When more candidate
facts are genuinely needed to know eligibility or uniqueness, the read stays
necessary and its failure keeps the row incomplete.

## 3. Decide and freeze identity

Apply the identity rules in `identity-and-source-boundaries.md`. Every
successfully completed physical row ends in exactly one identity state:

- `Matched — [platform account name] [visible scope]`, or
- `No match — [short reason]`.

A row that has not successfully completed — a transport, authorization,
upstream, or client-state failure — takes precedence over these outcomes and
stays incomplete. It cannot enter a completed matched/no-match total, and the
whole run is not complete until it is recovered.

There is no terminal review or "Identity needs review" state. Internal
uncertainty is resolved by the bounded recovery above and then becomes a
decision. The default is the account name the user supplied: resolve that
supplied name, and if it stays unmatched after bounded recovery, complete the
row as `No match` with the actual reason (for example an absent account, a
material contradiction, or an unresolved ambiguity) — do not search a parent,
family, or network account to substitute for it. A related parent, family, or
network account is searched only when the user has expressly requested a
broader search beyond the named account — for example, group-wide opportunity
discovery — and never merely because the row carries a group column. A supplied
group name that does not match is not promoted to its own further parent; that
cell simply ends as `No match`. Prefer the exact subsidiary or operating
account. For an expressly requested broader search, send it as a separate
retrieval query — the
candidate tool's `alternate_query` with basis `family_network`, keeping the
submitted name and the original physical row ID on the row — and select the
nearest clearly supported available account. Record
`match_basis: parent_fallback` and a declared scope of `family` or `network`.
Do not trigger this search merely because a matched subsidiary has no partner
relationships. A family/network connection is never reported as an exact scope,
and a mere exact-scope mismatch
does not by itself block a supported family/network selection. The connection
must be established by corroborating evidence returned for that account, or —
only when the user has explicitly authorized external research — by an
attributable authoritative company, brand, or network source with its URL
and retrieval date, labelled external; unverified sheet cells or conversation
statements may guide the search but cannot establish it, create a Luasai graph
fact, or authorize a reveal. Record the connection provenance and scope on the
row. Competing or
conflicting assertions need a bounded evidence resolution, then `No match` if
they stay unresolved, while a failure stays incomplete.

For every row, record:

- preparation stages and their modes inspected (page is inapplicable for the
  single-pass bulk lanes), or actual pages for an operator investigation;
- selected platform account ID and name, or an explicit no-match reason;
- strongest supporting fields;
- material contradictions checked;
- concise rationale;
- whether another page or missing user evidence could change the decision; and
- the bounded recovery record for any zero-hit or no-match row.

For every no-match, also record `strong_candidate_audit` entries for all flagged
returned profiles. Each entry includes candidate ID, inspected mode/page and
rank, positive field, and a concrete contradiction or resolution. The audit
must cover every returned candidate on every inspected page. A row cannot be
finished as no-match while exactly one uniquely defensible flagged candidate
remains. When multiple distinct flagged candidates remain defensible, apply the
source-context comparison from `identity-and-source-boundaries.md` first; if it
uniquely resolves one eligible candidate, freeze it. If the returned facts
already show the choice turns only on client intent, the row completes as an
ambiguity `No match` before the optional read. Otherwise record their IDs and
the specific missing discriminator, and use bounded recovery or the optional
read only for a genuinely missing candidate fact that could change eligibility
or uniqueness.

A bounded retrieval miss is not a publicv2 coverage conclusion. Distinguish:

- retrieval exhausted without the intended entity;
- ambiguous candidates;
- material candidate contradiction;
- candidate-search failure; and
- adjudicated governed-data coverage gap.

Freeze one platform account ID or one no-match for every physical row before
graph search. Before freezing, perform the second-pass positive-evidence audit
from `identity-and-source-boundaries.md` across every proposed selection; this
uses the retained profiles and makes no new MCP call. Run the corresponding
candidate audit across every proposed no-match in the same pass. Preserve the
inspected mode/page path for no-match rows in the audit output. Do not silently
revise identity because a later relationship result is more commercially
convenient.

### Client decision receipts

Write one client-side decision receipt per physical row, matching the evaluator
schema exactly (`object_version: account-list-decision-receipt-v1`). Receipts
are client-side audit artifacts, not MCP tool arguments, and their field names
are not customer-facing jargon. Record:

- `input_id` — the exact physical row ID;
- `object_version` — exactly `account-list-decision-receipt-v1`; any other
  version is unsupported and the row is incomplete;
- `model_version`, `prompt_version` — if the client cannot determine its own
  model or prompt version, write the literal string `unknown` rather than
  inventing a value or omitting the field. `model_version` and `prompt_version`
  may be `unknown`; `object_version` may not;
- `execution_status` — `completed`, `failed`, or `incomplete`;
- `outcome` — `matched` or `no_match`, present only for a completed row;
- `initial_candidate_count` — a non-negative integer required for every
  completed outcome. On the normal path it is the count in the preparation
  receipt's successful initial `bulk` row. On the operator path it is the count
  in the first successful `fast` response (page one). It is not an accumulated total across
  recovery stages, variants or pages; a failed request contributes no count and is never
  recorded as zero, because a zero-hit row must carry a recovery record. The
  one narrow exception is a locally unusable input row: an empty or
  one-character name with no usable domain or context, after checking every
  usable alternate hint, may record `initial_candidate_count: 0` with
  `reason_code: invalid_input`. That zero is an explicit local-validation
  convention, not a claim that a tool returned zero candidates. The row still
  completes as `No match`, its `attempted_variants` explain the local validation
  and that no request was sent, and its `fallback_inapplicable_reason` explains
  the insufficient input. The same completion applies when the source name is
  longer than the bounded retrieval query and no grounded bounded variant can be
  established from the row: the tool reports `source_name_too_long`, and the
  original cell value is preserved and never searched as a truncated prefix. A
  transport, authorization, or client-state failure is never `invalid_input` and
  remains incomplete;
- `selected_platform_account_id` — the selected public account ID, present only
  for a matched row;
- `declared_scope` — `exact`, `family`, or `network`, present only for a matched
  row and consistent with `match_basis`: `exact` scope pairs with `exact`, and
  `family` or `network` scope pairs with `parent_fallback`;
- `match_basis` — `exact` or `parent_fallback` for an identity selection;
- `reason_code` and `evidence_references` (non-empty for a matched row);
- for fallback, the requested entity, the selected account, the outcome of the
  original lookup, and the evidence supporting the family/network connection;
- `recovery` — `attempted_variants`, `fallback_attempts`, and a
  `fallback_inapplicable_reason` when fallback does not apply, required for a
  completed no-match and for any zero-hit row, including a zero-hit row that
  ends matched after recovery. `attempted_variants` records the actual retrieval
  strings the run issued, the original effective query first even when no
  derived name variant was used; when the source name is longer than the bounded
  query and an `alternate_query` is issued instead, record that issued string
  and keep the submitted source name separately in `submitted_name`. Repeating
  the original query in a later mode or page stays described under
  `fallback_attempts` by its mode and page and does not require inventing
  another name; an empty `attempted_variants` ledger is invalid even when
  `fallback_attempts` is populated; and
- any error, recorded as an execution failure, never as a no-match.

`related_discovery` is not an identity basis; it is reserved for broader
opportunity discovery and cannot stand in for a matched identity. A completed
no-match must carry `selected_platform_account_id`, `declared_scope`, and
`match_basis` as `null` or omit them. A failed execution has no completed
identity outcome and cannot satisfy the row completion gate. Retain the receipt
in client working state even when the user only wants chat results and no file
is written; do not require an artifact when none was requested.

Three compact synthetic examples — one matched and two no-match (one
retrieval-exhausted, one locally unusable input) — show the shape the evaluator
accepts. They use placeholder IDs and are not customer data:

<!-- receipt-examples:start -->
```json
[
  {
    "input_id": "example-sheet-2",
    "submitted_name": "Example Trading Company",
    "object_version": "account-list-decision-receipt-v1",
    "model_version": "unknown",
    "prompt_version": "unknown",
    "execution_status": "completed",
    "outcome": "matched",
    "initial_candidate_count": 3,
    "selected_platform_account_id": "00000000-0000-0000-0000-0000000000a1",
    "declared_scope": "exact",
    "match_basis": "exact",
    "reason_code": "evidence_supported_exact_match",
    "evidence_references": ["https://example.test/evidence/example-trading"]
  },
  {
    "input_id": "example-sheet-3",
    "submitted_name": "Absent Trading Company",
    "object_version": "account-list-decision-receipt-v1",
    "model_version": "unknown",
    "prompt_version": "unknown",
    "execution_status": "completed",
    "outcome": "no_match",
    "initial_candidate_count": 0,
    "reason_code": "insufficient_evidence",
    "recovery": {
      "attempted_variants": [
        "Absent Trading Company",
        "Absent Trading Co",
        "Absent Trading Company Inc"
      ],
      "fallback_attempts": ["searched the evidenced absent-network account"],
      "fallback_inapplicable_reason": null
    }
  },
  {
    "input_id": "example-sheet-4",
    "submitted_name": "",
    "object_version": "account-list-decision-receipt-v1",
    "model_version": "unknown",
    "prompt_version": "unknown",
    "execution_status": "completed",
    "outcome": "no_match",
    "initial_candidate_count": 0,
    "reason_code": "invalid_input",
    "recovery": {
      "attempted_variants": [
        "local validation: empty submitted name and no usable domain or context; no candidate request sent"
      ],
      "fallback_attempts": [],
      "fallback_inapplicable_reason": "insufficient input for a bounded retrieval attempt"
    }
  }
]
```
<!-- receipt-examples:end -->

## Later stages

This module freezes one identity decision and one client decision receipt per
physical row. The requested relationship, reveal, and writeback stages live in
`relationship-writeback-stage.md`; read it only when the user has actually
requested partner relationships, a paid reveal, or a written output. An
identity-only lookup stops here.
