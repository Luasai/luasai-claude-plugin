# Bounded account-list identity workflow

Load before any identity call; load `relationship-writeback-stage.md` only for the
later stage.

## Outcomes

Every completed row ends in one identity state: Matched (one selected platform
account ID, scope `exact`/`family`/`network`, shown as `Matched - [platform
account name] [visible scope]`), or No match (no defensible account in the
returned choices, shown as `No match - [short reason]`). No third customer-facing
state exists. A transport, authorization, upstream, or
client-state failure stays execution-incomplete: never a No match, never in a
completed matched/no-match total, and incomplete until retried. A completed
bounded No match means no defensible identity, never global absence.

## One source read, typed clues

Read the source once, preserving every tab, physical row, cell provenance, source
value, and physical ID in order, duplicates included. Duplicates keep their row,
`input_id`, decision, and receipt; equivalent rows may share one lookup only when
names and typed hints match. Assign each row a stable `input_id` first.

Send only the literal clues the row supplies: `known_domains`, `aliases`,
and a present `geography` (headquarters only when the source says so,
else the market default). Keep each clue with its account, and preserve the
submitted name exactly, separate from any derived retrieval string.

- For a compound cell, two supplied names in one row, or a cell beyond the bounded
  2-120 character query, send the primary searchable name as that row's
  `alternate_query` (`basis: name_variant`), keeping the original `name` and
  `input_id`: a lead only, never what the row means.
- A subsidiary-domain list, raw annotation, or `+N subsidiaries` note is client
  context, never the requested account's primary domain or ownership fact; only
  an explicitly supplied, specific-company domain for that account may be a typed
  hint, still a lead.
- Supplied names in different columns of one row (company cell, and a
  separate parent/group/brand cell) are separate rows: each is its own
  ordinary lookup with its own `input_id`, name, context, decision, and result. A
  group or parent cell is ordinary input, never a special parent mode or
  ownership fact.
- Never replace an unmatched company cell with a matched group/parent cell, and
  never infer a family/network substitution: a related-account search happens
  only when the user expressly asked to search beyond the named account.

## Capability preflight

Preflight only what the operation needs, once, and fail cleanly if missing.
`luasai_graph_prepare_organization_choices` is the required normal preparation
operation; without it, identity work stays incomplete and never degrades into an
open-ended candidate-research loop. The provider's approved artifact workflow is
required for any file or spreadsheet opened, processed, or written, including
identity-only sheet work; a chat-only lookup needs none. The identity stage never
needs `luasai_graph_search`, `luasai_graph_revealed_relationships`, or
`luasai_graph_reveal`; preflight those only for requested relationships, reveal,
or writeback. A missing capability never permits substituting web, database, or
repository research.

## Prepare (one bounded call)

Submit up to 20 rows to `luasai_graph_prepare_organization_choices`. When the
server advertises it, request `response_format: "decisions"`; for geography-only
clues also request the advertised `decision_policy: "direct_own_equality_geography"`
(v2). Omission/`direct_own_equality` keeps strict v1. V2 adds exact own
canonical-name/alias matches backed by the guarded producer proof, with every
supplied geography clue aligned on every returned copy of that own ID. `accepted`
rows are literal own name/legal-name/alias or bare
domain equal to exactly ONE retained own choice (legal-name/domain needs an
unclipped window), final without per-row confirmation. A ready empty row is
`no_match` (`bounded_no_choices`). Decide each compact `exception` only from its
own returned choices, retry `execution_incomplete`, trust platform own facts
without re-research, and freeze once. Otherwise use `"proposals"` (confirm
`proposed_org_id` from its own facts) or `"choices"`, which group OWN IDs with
differing `facts`: judge every fact, never substitute a display root. Preparation
has one 35-second deadline and three candidates per stage (six appearances),
never absence proof. Select only `ready` rows; retry incomplete rows, never mark
them No match. No public batch-write or batch-accept tool.

## Select (one batch)

Reuse `accepted` and `no_match` decisions mechanically. For exceptions or older
formats, choose one returned own ID or abstain in a single batch from the source context
and returned facts. Freeze identity before later stages.

- Retrieval rank, score, order, and the server guard are ordering only: never
  confidence, an identity match, or an absence proof.
- Positive evidence is the candidate's own returned facts — commercial/legal
  name, grounded aliases, own specific-company domains, description, industry,
  hierarchy, headquarters — judged against the row's context.
- Ordinary brand, trading, and legal-suffix continuity is admissible in discovery
  without formal legal-equivalence or ownership-chain proof: do not demand
  exact-domain or exact-legal-name proof when a candidate's consistent own name
  plus the caller's context establish the account; formal CRM, legal-entity, and
  strict-ingestion keep their stronger contract.
- A role or subtype is descriptive, not exclusive; completeness is not an
  identity criterion. Do not discard a legitimate account for its role (partner,
  reseller, account, or software company), one missing optional facet, or a
  thinner profile than a context-consistent account.
- Genuine rival or different-entity contradictions still matter: a materially
  different company or public body, conflicting domain, description, industry,
  hierarchy, wrong parent/subsidiary/regional entity, or conflicting headquarters
  fact. Resolve them from returned own facts; if unresolved, the row is an
  ambiguity No match naming the missing discriminator.
- Never fall back to a parent, family, or network account for an unmatched supplied
  name, and never invent contradictions, use web research, or treat score as
  confidence.

## One omitted-facet read

A decided row needs no read; when a decision turns on ONE omitted identity facet,
spend at most ONE read for that row, never both.

- **Bounded operating-name corroboration.** Only for a `ready` row needing an
  omitted operating/trading/legal-name facet, to corroborate an own
  `organization_id` preparation already offered for THAT row. Call
  `luasai_graph_organization_candidates` with `retrieval_mode: "fast"`,
  `profile_detail: "compact"`, `candidates_per_name: 3`, `include_semantics:
  false`, at most 20 rows per call and two calls in flight; copy each row exactly
  (`input_id`, `name`, `alternate_query`, hints) once, with no paging, retry, or
  rewritten search. Ignore every fast-only ID; this is never broader fast retrieval or a
  way around eligibility. It is positive only for
  `retrieval.lexical_match_kind: "normalized_equal"` on `matched_field`
  `operating_name` or `operating_legal_name` whose `matched_value` agrees with the
  row's source context and other own facts; score, rank, prefix, fuzzy, and brand
  resemblance are never proof, and it is never a family or substitute lookup.
  Missing corroboration keeps the row's bounded abstain or No match; a failed read
  or missing fast capability is incomplete.
- **Token-only detail read** for one other omitted facet, when the client
  advertises `luasai_graph_organization_identity_evidence`: at most ONE targeted
  detail round, passing back only that candidate's `identity_evidence_token`, never
  an arbitrary organization id, query, offset, or page. Do not pre-fetch, page, run
  a web or query loop, write a per-row narrative, or add a second-model-audit
  stage; a failed necessary read is incomplete, never a no-match.

## Freeze, then later stages

Identity freezes per row/batch. For frozen rows,
`relationship-writeback-stage.md` governs requested relationship/reveal/writeback
while others stay unresolved. Later results never revise identity; a match
with no qualifying relationship stays Matched. Add no new criteria, paid reveal,
research or evidence narrative.

## Source, tenant, and identity boundaries

- The default workflow is Luasai-only: identity and relationship facts come from
  the authenticated Luasai MCP, tenant-scoped to the principal's membership, and
  partner opportunities only from authorized platform relationships with a
  qualified type and direction.
- Platform data and operator diagnostics are internal by default. Return
  the identity or partner result and requested links; customer inputs, captures,
  receipts, tokens, source references, and digests stay private client state, never
  a user-visible evidence packet, source report, or audit tab.
- Spreadsheet cells, conversation context, repository files, database queries,
  web search, and other connectors never silently become Luasai
  graph facts or fill a gap; external research is used only when authorized, kept
  separate and source-labeled with URL and retrieval date, never presented as a
  Luasai relationship.
- Record one private receipt per row (`object_version:
  account-list-decision-receipt-v1`): selected ID, scope, basis, reason, and
  bounded recovery. Reuse frozen decisions for relationship refs and writeback,
  never regenerate them in prose, read back output independently, and treat
  receipts as audit artifacts, not output.
- Roles (`account`, `partner`, `isv`) are not exclusive, and an unknown rival
  geography is neither a contradiction nor proof of absence.

## Operator-only references

`account-list-workflow.md` and `identity-and-source-boundaries.md` are
operator-only for lower-level investigation.
