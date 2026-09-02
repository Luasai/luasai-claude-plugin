# Identity and source boundaries

The Luasai candidate tool retrieves potentially relevant governed profiles. It
does not decide which organization the user meant. The client agent makes that
decision from the returned profiles plus client-local context.

## Evidence hierarchy

Compare the submitted entity against every candidate using:

1. exact specific-company domain alignment;
2. legal name, distinctive name tokens, and grounded aliases;
3. description and organization class;
4. industry and sector;
5. parent, display-root, subsidiary, and regional-entity hierarchy;
6. explicit headquarters or operating geography; and
7. local Market, territory, role, or notes as non-authoritative context.

Retrieval rank, lexical score, semantic similarity, type hint alignment, and a
shared country explain ordering only. They do not establish identity.

## Selection rule

Selection is fail-closed. Before freezing any selected row, record both
`positive_identity_evidence` and `contradictions_checked`. Select only when at
least one of these positive gates passes and no material contradiction remains:

1. the normalized submitted name equals the candidate name, legal name, or a
   grounded alias after removing only punctuation and ordinary legal suffixes;
2. every distinctive submitted-name token is supported by the candidate name,
   legal name, or grounded alias, while domain, description, or hierarchy
   confirms the same entity or a genuine expanded name; or
3. a user-supplied specific-company domain exactly matches a primary or
   verified candidate domain.

Description, industry, geography, retrieval score, semantic similarity, rank,
or a relationship result may corroborate a passed gate but cannot replace one.
If only one distinctive token remains, a longer candidate name that merely
contains that token does not pass without exact alias, domain, description, or
hierarchy support for the same entity. A different legal form, subsidiary,
business line, public body, or added distinctive name is a contradiction until
the returned profile explicitly reconciles it.

Ordinary corporate expansion is not an added distinctive identity. For
example, a submitted brand followed by generic scope or legal terms such as
`group`, `holdings`, `international`, `corporation`, `limited`, or `plc` can
pass when the distinctive submitted tokens remain intact and the returned
alias, specific-company domain, description, or hierarchy corroborates the
same organization. An acronym with a parenthetical or alias expansion can also
pass when that expansion contains the complete distinctive submitted name.
These rules identify evidence to inspect; they do not turn rank or token
overlap into an automatic match.

Country, regional, sub-brand, product, business-unit, and joint-venture words
are distinctive modifiers, not ordinary corporate expansion. For example,
`Vodafone Qatar` and `Vodafone Idea` are not interchangeable with a submitted
bare `Vodafone` merely because they share the parent brand or expose a bare
brand alias. Treat the added modifier plus conflicting description, geography,
domain, or hierarchy as a different-entity contradiction unless the returned
profile explicitly reconciles that candidate as the exact requested group or
root. Do not count such candidates as independently defensible when testing
whether multiple strong candidates remain.

## Mandatory pre-abstention audit

Before freezing any abstention, scan every candidate on every page already
retrieved for that physical row, not only rank one or the last page. Create a
short `strong_candidate_audit` entry for each candidate that meets any of these
conditions:

- normalized candidate name, legal name, or grounded alias equals the
  submitted name after ordinary legal suffix removal;
- the complete distinctive submitted token sequence remains intact and the
  candidate adds only ordinary corporate scope or legal terms, with returned
  profile corroboration;
- a grounded alias contains the complete distinctive submitted name; or
- an acronym or parenthetical expansion contains the complete distinctive
  submitted name.

First group repeated appearances by stable organization ID. A profile returned
in fast and semantic mode, or on more than one inspected page, is one candidate,
not evidence of multiple entities. Retain all occurrence paths and merge only
non-conflicting returned fields for its audit entry. A material identity-field
conflict between copies does not disappear through deduplication: the candidate
cannot be selected unless an explicit returned authoritative field reconciles
the copies. If it is the only positive-gate candidate, abstain and record the
conflicting fields rather than preferring the more complete copy.

For each distinct flagged candidate, record the candidate ID, page, rank,
positive field, and any explicit returned-field contradiction. Collect every
candidate that passes a positive gate after the complete different-entity
contradiction review. Shared brand token overlap alone is not a positive gate.
Select only when exactly one candidate remains, or when explicit user-supplied
row context and returned fields uniquely disambiguate one from the others.
Rank and retrieval score cannot break a tie. If two or more distinct profiles
remain independently defensible, abstain and name their IDs, positive fields,
and the specific missing discriminator. This explicit multiplicity rationale is
sufficient; do not invent a contradiction to force a choice. A blank statement
such as "no unique defensible identity" remains insufficient when it omits the
competing profiles or leaves a single candidate unresolved.

Do not downgrade a uniquely defensible fast candidate merely because semantic
results also exist or because the candidate carries a non-exclusive role such
as partner. Once exactly one fast candidate passes a positive gate and the
contradiction check, freeze it and do not spend a semantic call on that row.
Equivalent duplicate physical rows may reuse the same audited identity decision
when their typed hints do not conflict, while retaining separate row receipts.

Run a second model-side audit over the complete frozen-selection proposal
before graph search. Reject any row whose recorded positive evidence does not
appear in that row's returned profile, even if the candidate is rank one or the
only result. Examples of forbidden token or semantic leaps include URENCO to
Ralph Lauren, British United Provident Association to Unite Group, Kaizen
Reporting to Zen, a parent brand to an unrelated same-brand subsidiary, or a
holding company to a similarly named operating company.

Abstain, ask for a confirming domain or legal name, or retrieve another
plausible page when any material contradiction remains. Typical vetoes include:

- displayed or legal name denotes a different company or public body;
- primary or verified domain belongs to a different organization;
- description identifies a materially different institution or business;
- industry or sector makes the name similarity coincidental;
- the candidate is the wrong parent, subsidiary, or regional operating entity;
  or
- an explicit headquarters fact conflicts with the intended legal entity.

Geography can break a tie between otherwise plausible entities, but a matching
Market cannot rescue a candidate with a conflicting name, domain, description,
industry, or hierarchy. A role such as partner, reseller, account, customer, or
software company is descriptive rather than mutually exclusive.

Record a concise rationale naming the strongest positive evidence and the
material contradictions checked. For abstentions, also retain every inspected
mode/page and the `strong_candidate_audit`; do not leave the candidate path
blank. Do not write hidden model confidence as if it were a Luasai score.

## Source policy

The default workflow is Luasai-only:

- organization and relationship facts come from the authenticated Luasai MCP;
- spreadsheet cells and conversation context may guide client-side selection
  but do not become Luasai graph facts;
- repository files, direct database queries, generic web search, and other
  connectors must not silently fill a Luasai gap; and
- if the user explicitly requests external research, keep it in separate
  source-labeled columns or a separate section with URL and retrieval date.

Never present external research as a Luasai relationship. A blank caused by
missing Luasai evidence remains blank in the Luasai column.

## Data-health observations

During normal work, `luasai_graph_report_data_issue` may be used when the
returned trusted publicv2 profile itself exposes a concrete wrong, missing,
stale, conflicting, or duplicate fact. Internal contradictions between its
name, legal name, aliases, domains, description, industry, geography, or
hierarchy can qualify.

Do not report:

- a candidate that is merely not the user's intended company;
- ordinary ambiguity or a retrieval miss;
- a missing relationship;
- private spreadsheet or CRM content;
- personal data or secrets; or
- unsupported suspicion.

The report is an untrusted suggestion for Luasai review and never changes the
current profile or ranking. An official external URL already present in the
task may be labeled as non-canonical corroboration, but external material does
not assert a replacement graph fact. Continue the user's task with the best
supported current evidence.
