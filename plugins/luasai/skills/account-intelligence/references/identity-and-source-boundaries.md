# Identity and source boundaries

> **Operator-only.** Retained with `account-list-workflow.md` for an explicit
> lower-level investigation. The normal default identity load is
> `bounded-account-list-workflow.md`.

The Luasai candidate tool retrieves potentially relevant governed profiles. It
does not decide which organization the user meant. The client agent makes that
decision from the returned profiles plus client-local context.

## Candidate response explanation block

The candidate response carries a static `candidate_semantics` explanation block
by default. It restates the selection, recovery, pagination, provenance, and
write boundaries in this module as data; it is never an identity decision, the
block is redundant once the identity references are loaded, and opting out never
removes a rule from the workflow. The optional `include_semantics: false`
opt-out, its condition that both identity references are already loaded, and its
no-probe rule are defined in `account-list-workflow.md`; apply them there rather
than restating them. The flag never enters a token or cursor, and it never
changes the separate identity-detail read described below.

## Completed identity outcome

For a multi-row account-discovery run, every successfully completed physical
input row ends in exactly one identity state:

- **Matched — [platform account name] [visible scope]**: exactly one selected
  platform account ID with a declared scope of `exact`, `family`, or `network`.
- **No match — [short reason]**: no defensible platform account was established
  after the bounded recovery below.

There is no customer-facing third identity state such as "Identity needs
review", and no per-row customer approval queue. Internal uncertainty is
resolved by bounded automated recovery and then becomes a decision. A no-match
means this workflow could not establish a defensible platform-account match
from the evidence it could reach; it does not assert that the organization does
not exist in Luasai.

Only successfully completed rows receive one of these states. A transport,
authorization, upstream, or client-state failure takes precedence and stays
incomplete: it cannot enter a completed matched/no-match total, and the whole
run is not complete until it is recovered.

A matched row keeps its identity even when it has zero qualifying partner
relationships. Identity and partner availability are separate: a matched
account with no returned partners remains Matched. Broader family/network
partner discovery is a separate, user-requested decision, never an automatic
fallback and never a reason to replace a valid identity.

Execution failure is not an identity outcome. A transport, authorization,
upstream, client-state, or write failure leaves the row incomplete: retry the
failed row, keep the successful ones, and report an incomplete run when
recovery fails. Never convert a lookup failure into No match.

A source row that is locally unusable — an empty or one-character name with no
usable domain or context and no usable alternate hint to check — completes as
`No match` with reason `invalid_input`, not as an infrastructure failure and
never with an invented result. Its receipt records the zero candidate count as
an explicit local-validation convention and states that no candidate request
was sent. A short original name is only insufficient input when no grounded
bounded variant exists: check usable row context and alternate hints first, and
when one supports a grounded 2–120-character variant, send it as that row's
`alternate_query` — the original short name itself is never sent to search. The
candidate tool then reports that row as `insufficient_input`, so the same
insufficient-input condition is visible at both the tool error code and the
receipt reason. The same completion covers a source name longer than the bounded
2–120-character retrieval query when no grounded bounded name variant can be
established from the row: the tool reports `source_name_too_long`, and the
original cell value is preserved and never truncated into a searchable prefix or
turned into a false empty search. Consult `account-list-workflow.md` for that
receipt shape.

## Evidence hierarchy

Compare the submitted entity against every candidate using:

1. exact specific-company domain alignment;
2. the own commercial name, its distinctive name tokens, grounded aliases, and
   the stored legal name;
3. description and organization class;
4. industry and sector;
5. parent, display-root, subsidiary, and regional-entity hierarchy;
6. explicit headquarters or operating geography; and
7. local Market, territory, role, or notes as non-authoritative context.

Retrieval rank, lexical score, semantic similarity, type hint alignment, and a
shared country explain ordering only. They do not establish identity.

Use `retrieval.matched_field`, `retrieval.matched_value`, and
`retrieval.lexical_match_kind` to see which stored name, domain, alias, or
operating name produced a candidate. `lexical_match_kind`, especially
`normalized_equal`, is string evidence only: never an identity match and never
family/network proof. A shortened ambiguous initialism that is merely
string-equal to a stored alias stays unresolved while the full source cell's
annotations remain unexplained and an actually inspected distinct account is a
plausible same-core-brand or same-initialism rival: retain that rival instead of
discarding it for lacking the shortened bare alias, for not independently
passing an ordinary exact-name or alias gate, or because another candidate is
`normalized_equal`. Resolve the row only on coherent full-source and own-profile
support under the gates below; if that support is missing, keep the rival in the
audit and finish via bounded recovery then an unresolved-ambiguity `No match`
rather than inventing evidence for either side. This is not a new exact-alias
precedence and adds no mandatory full-cell search, extra query, or name-query
order: the existing full original and grounded primary-name recovery is
unchanged, an exact own short brand with no unresolved plausible rival still
passes, no blanket source-acronym expansion is required, and the rule penalizes
neither every annotated cell nor every longer-name token overlap. A matched
operating name belongs to the same canonical account, not a separate one.

The low-authority fuzzy `trigram_fill` kind is the weakest form of this evidence:
bounded fuzzy name similarity over a candidate's own stored name. A
`trigram_fill` candidate is a retrieval lead only — never identity confidence, a
match, or proof of a parent, family, or network relationship. Before recording
the binary completed outcome, judge its `organization_id` against the submitted
source row with that profile's own returned name, legal name, aliases, domains,
description, and hierarchy, and keep a matched exact subsidiary ahead of a
merely similar or related account. Fuzzy retrieval alone can neither promote a
candidate to a match nor turn an unresolved row into a completed `No match`.

`matched_field` also names a `primary_domain` or `verified_domain` hit.
`primary_domain` is the account's actual primary domain; `verified_domain` is a
stored verified domain claim on the same public canonical account and may sit on
the primary domain or on a different one. A caller-supplied known-domain or
known-alias hint can contribute a bounded candidate lead taken from the stored
value it names, but that is still an equality of a stored value and a retrieval
lead only — never source identity, a match, or a family or network proof.
Because a domain can be shared, a supplied domain that matches more than one
organization stays a separate lead for each and is never evidence that those
organizations are one family.

A domain-shaped candidate query keeps the exact-domain lane's existing
precedence. When that lane returns any candidate, those candidates are the
retrieval seed set and the supplied hints only re-rank them on that query —
they do not add a candidate from another hint owner. When the lane returns
none, the request falls through to the hinted fast path, where the supplied
domain/alias hints contribute the bounded seeds.

## Exact selection rule

Selection is fail-closed and applies to discovery of the caller's own requested
commercial account. For an **exact** selection, record both
`positive_identity_evidence` and `contradictions_checked`, and select only when
at least one positive gate passes and no material contradiction remains; each
gate's full criteria and guards follow its lane below.

Retain the entire supplied cell as source identity, including annotations,
named entities, domains, and qualifiers. Choose useful grounded retrieval
strings under the existing bounded recovery rules; an `alternate_query` changes
what is searched, never what the row means. Raw annotations, subsidiary-domain
lists, and `+N subsidiaries` are client context, not platform ownership,
primary-domain, industry, country, or family facts. Do not automatically assign
their domains as the requested account's primary-domain hint. An explicitly
supplied specific-company domain attributed to the requested account may keep
its existing typed client-local retrieval hint; it remains a lead, not a
platform identity or ownership fact. Assess explicitly stated business, country,
or ownership context against the returned own profile without inventing facts.

1. the normalized submitted name equals the candidate name or a grounded alias
   after removing only punctuation and ordinary legal suffixes; a legal-name-only
   equality additionally requires the commercial corroboration in Gate 1 below;
2. every distinctive submitted-name token is supported by the candidate name,
   legal name, or grounded alias, while domain, description, or hierarchy
   confirms the same entity or a genuine expanded name;
3. a user-supplied specific-company domain exactly matches a primary or
   verified candidate domain;
4. a domain-shaped commercial name (Gate 4 below);
5. a bounded mechanical mixed-case abbreviation (Gate 5 below); or
6. a brand carried only by the candidate's own primary registrable domain label
   (Gate 6 below).

**Gate 1 — name, legal-name, and grounded-alias equality.** The ordinary
channel is the candidate's own canonical name or a grounded alias equalling the
normalized submitted name, under the contradiction checks below. A
`legal_name`-only equality is not sufficient on its own when the candidate's
own commercial name and grounded aliases do not carry the submitted name: it
also requires the candidate's independently coherent own commercial identity,
i.e. its returned commercial name or grounded aliases together with its own
specific-company domain and its own consistent business facts. Those returned
facts must establish that the submitted name identifies that same own commercial
account; mutual consistency about a different brand alone is insufficient. A legal-name-only
equality therefore cannot on its own select a differently branded operating or
legal entity the caller did not ask for, and it still fails closed on any
material contradiction or an unresolved source-context ambiguity. This
corroboration requirement applies to that one field only: it is not a new
exact-alias precedence, and it does not make a domain mandatory for every match.
Ordinary exact own-name, canonical-name, and grounded-alias selection keeps the
same gate as before, and the strict formal-CRM/legal-entity and ingestion
contracts remain unchanged.

**Gate 4 — domain-shaped commercial name.** An exact stored primary or verified
domain keeps its precedence. Otherwise a submitted registrable label supports
the intended commercial account only when the candidate's unique own name or
grounded alias matches that label, the candidate's own primary or verified
brand domain uses that label, and the returned business facts and actual
supplied source context cohere, with no materially conflicting or same-label
independently defensible competitor. A different top-level domain by itself is
never proof of continuity or ownership. Never add the submitted, unverified
domain to the candidate's claims or report it as verified, and never treat a
country ccTLD or a headquarters match alone as proof of ownership or of a
distinct entity; a meaningful geography or business conflict still blocks.

**Gate 4 — own former commercial-name bridge (discovery only).** When the
domain-shaped submitted label matches none of the candidate's current primary
or verified domains, the exact-domain lane cannot bridge it and the
different-top-level-domain limit above still holds. In that one case only, the
submitted label may instead bridge through the candidate's own returned history:
the candidate's own profile must explicitly assert a former commercial or
trading name and its continuity to the candidate's own current identity, and
that asserted former name must equal the submitted label's registrable label
under case, punctuation, and spacing normalization with only ordinary trailing
legal-suffix removal — for the fictional label `oldharborpayments.com`, the
candidate's own profile stating it formerly traded as `Old Harbor Payments` and
now operates under its current commercial name. The candidate's own historical
assertion is the positive proof; the submitted domain itself stays unverified.
Never infer the history from the label alone, never strip or add meaningful
words to force a match, and never use an unrelated subsidiary, parent, family,
or customer mention, generic history, or an external or model prior as the
bridge. Require the candidate's own current commercial facts to stay coherent,
no material source contradiction, and no independently defensible unresolved
rival. A missing former-name fact simply leaves this bridge inapplicable; when
the compact candidate facts truncate the own history, read that candidate's own
identity evidence inside the existing shared two-read allowance, and a required
read that stays unavailable leaves the row incomplete rather than a no-match.
This expands Gate 4's discovery criteria only: the exact-domain precedence is
unchanged, the other gates are unchanged, and a former-name bridge never creates
or repairs a stored alias, asserts domain ownership or legal equivalence, or
introduces a new public outcome — the row keeps the same client decision
receipt.

**Gate 5 — bounded mechanical mixed-case abbreviation.** A full in-order
submitted label may be mechanically supported by the candidate's own returned
name when that name preserves the label's embedded uppercase or camel-word
capitals and removes only ordinary trailing legal suffixes — for the fictional
example `RVHarbor Payments Co`, the embedded `RV` plus `Harbor` H and
`Payments` P give `RVHP`. This uses no external knowledge and persists no alias.
Pure ordinary-word initials by themselves stay insufficient, and a
source-context-free acronym auto-pick is forbidden. Require an actual
mixed-case or embedded abbreviation — not arbitrary capitalization, a
subsequence, or skipped words — plus the candidate's own full brand-domain
consistency, corroboration from the actual supplied source context (never an
industry invented from a city), and no other defensible same-initialism
candidate. An uncorroborated initialism stays **No match**, and a
domain-shaped submitted label is unverified input rather than owned evidence.

**Gate 6 — own branded primary domain despite a different platform name.**
The submitted core commercial brand may be absent from the candidate's own name
and grounded aliases when its OWN primary registrable domain label equals that
brand under case, spacing, and punctuation normalization only. Require coherent,
non-empty substantive own returned business/profile facts, no material
contradiction with the supplied context, and no unresolved plausible competing
account among the actually inspected returned candidates. A brand-only source
need not supply a domain, industry, or country; an empty own profile is
insufficient. No classification of the platform name as formally legal is
required. A brand differing from the account's own formal name is not by itself
a different-company contradiction when these criteria pass; returned facts
identifying another commercial entity still block.

Public-suffix parsing identifies the registrable label, not continuity across
top-level domains or legal equivalence. Never strip or add domain words, accept
fuzzy/prefix/substring/hosted-subdomain labels, or substitute a verified-only,
sibling, or parent domain or invented ownership. This lane is independent of
Gate 4's own-name requirement and leaves the other gates unchanged. Audit the
own business/profile facts, supplied context and every inspected rival; keep
source modifiers and the existing bounded continuation, seed-recall, and
ambiguity rules. A bounded page proves no global uniqueness.

Description, industry, geography, retrieval score, semantic similarity, rank,
or a relationship result may corroborate a passed gate but cannot replace one.
If only one distinctive token remains, a longer candidate name that merely
contains that token plus corporate or generic terms is not enough on
containment. That row needs an own returned fact establishing this same
requested brand/account: a grounded own brand alias, the candidate's own
brand-bearing primary label under Gate 6, an own description explicitly
establishing this account's own requested commercial or trading brand, or
returned own-identity facts — not a related account's name. A longer-name
variant alias, a generic coherent longer-name business description, the search
normalizer's `normalized_equal` after only dropping corporate words, or a
verified-only domain by itself is not that bridge. This does not negate Gate 3: an actual caller-supplied specific-company
verified-domain match keeps that gate, subject to the existing contradiction,
shared-domain, and uniqueness checks.

Ordinary corporate expansion is not an added distinctive identity: when the
full distinctive submitted sequence stays intact and the candidate's own
returned name and corroborating facts support the same organization, a longer
name that adds only generic scope or legal terms such as `group`, `holdings`,
`international`, `corporation`, `limited`, or `plc` remains an ordinary
expansion that passes; the single-distinctive-token safeguard above governs
when only one distinctive token remains. An acronym with a parenthetical or
alias expansion can also pass when that expansion contains the complete
distinctive submitted name. These rules identify evidence to inspect; they do
not turn rank or token overlap into an automatic match.

An `exact` selection is the caller's own requested commercial account: never
legal-entity equivalence or domain ownership, never downgraded to `family`,
never replaced by a related account. The isolated legal-surface exception
requires all of the candidate's own commercial-name equality or grounded brand
continuity, its own specific-company primary or verified brand domain, and its
own consistent business description to agree, with no conflict in the actual
supplied context and no independently defensible competitor. Missing support
for any of those checks does not qualify for the exception. Only then may one
isolated legal name — or an alias merely mirroring that same value — with no
corroboration in the candidate's own commercial name, domain, business, or
hierarchy remain an internal field-qualified data-health contradiction rather
than a selection blocker; `legal_name` is never blanket-ignored.
A legal form, subsidiary, business line, or public-body divergence corroborated
across the profile's own fields still blocks, as does any other
commercial-field, domain, business, or geography conflict, or an independently
defensible competitor. Scoped to discovery's own requested account, the
allowance does not broaden formal CRM, legal-entity, or strict-ingestion
resolution, and a request needing that stronger proof keeps its stricter
contract with no equivalence inference.

Country, regional, sub-brand, product, business-unit, and joint-venture words
are distinctive modifiers, not ordinary corporate expansion. For example,
`Vodafone Qatar` and `Vodafone Idea` are not interchangeable with a submitted
bare `Vodafone` merely because they share the parent brand or expose a bare
brand alias. Treat the added modifier plus conflicting description, geography,
domain, or hierarchy as a different-entity contradiction unless the returned
profile explicitly reconciles that candidate as the exact requested group or
root. Do not count such candidates as independently defensible when testing
whether multiple strong candidates remain.

**Display-root-linked narrower rival (discovery only).** Under the Gate 1 and
Gate 2 contradiction analysis, an otherwise-appearing rival whose own returned
`hierarchy.display_root_organization_id` equals the selected account's
`organization_id` — an actual returned-value equality between the two accounts,
never a link inferred from equal or similar names and never a shared brand or
shared domain — is a narrower entity of the selected account rather than an
independent competitor, but only when both hold: the rival is demonstrably
narrower from its own returned name or identity facts (its own returned name
adds a distinctive regional, country, sub-brand, product, business-unit, or
joint-venture qualifier to the complete requested sequence), and it does not
itself independently satisfy the requested own commercial identity. The
selected account must already carry the directly requested own canonical name
or grounded alias, and this link alone neither merges the two records nor
proves legal equivalence: both canonical IDs stay separate and are never
coalesced. Incomplete or missing rival facts never eliminate the rival — a
rival with unknown own facts stays, and the tie then remains ambiguous rather
than defaulting to the selected account. A requested specific subsidiary,
branch, business-line, domain, or entity qualifier always wins and is never
replaced by the broader selected account. This is not a parent or family
fallback, not a global alias precedence, and it never turns role (an ISV-only
role included), retrieval score, rank, order, or profile completeness into an
identity criterion.

These gates and contradiction rules govern an **exact** selection. The default
resolution is the account name the user supplied: resolve that supplied name,
and when it stays unmatched after bounded recovery end the row as **No match**
with the actual reason (for example an absent account, a material candidate
contradiction, or an unresolved ambiguity) rather than searching a parent,
family, or network account to substitute for it. A supplied parent, group, or
other column value is ordinary account lookup input for that physical cell, not
a special parent mode or an inferred ownership fact: it is resolved through the
same candidate lookup, under the same exact-selection gates, with its own
stable `input_id` and its own separate result. An unmatched company cell is
never replaced by a matched group cell from another column. A supplied group
name is only its own exact-name lookup: if it does not match, it ends as **No
match** for that cell — it is never promoted to its own further parent, and a
group column carries no family-relationship proof.

### Commercial eligibility and the country-context tie breaker

These gates govern discovery of the caller's own requested commercial account
only. They do not change formal CRM, legal-entity, or strict-ingestion
resolution, which keeps its stronger contract. A candidate is **eligible** when
it passes one of the positive gates above and has no material contradiction,
judged from the actual returned facts. Eligibility is necessary but not
sufficient: two or more eligible candidates can remain.

A bare name match never wins over an explicit source entity modifier. A supplied
exact domain and the full set of supplied entity modifiers govern before any
softer comparison, so a source-specific subsidiary, branch, business line, or
public body is never replaced by a parent or group on country alone.

When two or more candidates are eligible, rank, retrieval score, order, a
generic description, and profile completeness never decide. Roles, a top-level
domain, a city, and a billing country are not standalone identity
discriminators. A supplied country or market locating context may settle the
identity only when all of these hold:

- exactly one otherwise-eligible candidate's own returned headquarters or
  operating geography explicitly names that country or market;
- no other otherwise-eligible candidate independently corroborates it;
- no other otherwise-eligible candidate has missing or unknown locating
  geography, unless a different unique positive supplied discriminator already
  resolves that rival; and
- the selected candidate has no material contradiction to the source.

When they hold, select that candidate and rest the recorded rationale positively
on its own name and context facts. Record the non-selected eligible candidate(s)
privately with the missing discriminator. A rival's differing, missing, or
unknown geography is never described as a contradiction in the selected
candidate, and a rival is never called outside the country or the wrong company
on that basis: a rival's own differing geography may distinguish it, and a null
or unknown one neither conflicts nor proves absence. That same missing or
unknown geography is not a contradiction and never eliminates the rival, but it
does block the country context from settling the identity: a rival whose own
locating geography is missing or unknown could also operate the country, so the
locating context is not a unique discriminator while that rival remains and the
tie stays ambiguous unless a different unique positive supplied discriminator
distinguishes it. A null, boilerplate, or role field is not proof that a rival
is ineligible, and a billing country is corroboration only, never a headquarters claim.
If two or more candidates corroborate the country or market, if none corroborate
it, if no locating context was supplied, or if an otherwise-eligible rival's
locating geography is missing or unknown without another unique positive
supplied discriminator, the tie stays ambiguous. Missing rival geography is a
potentially discoverable candidate fact, not a reason to skip recovery: when it
alone blocks the country comparison, use the existing bounded recovery or
own-identity read — within the same budget, with no added read and no guaranteed
canonical result — because a recovered differing own geography can distinguish
the rival. If it still leaves that geography unknown, the row may complete as an
ambiguity `No match`; a necessary read that fails instead keeps the row
incomplete. A shared brand domain or a
supported display root does not collapse separate canonical IDs. Namespace,
country-kind, public-body, business, and geography contradictions that come
from the actual returned facts still block.

### Requested broader search: family, brand continuity and network scope

A related parent, family, brand, or network account is searched only when the
user has expressly requested a broader search *beyond the named account* — for
example, a request to expand to group-wide opportunities — never as an
automatic fallback for a supplied name that did not match, never inferred from
a source sheet cell, and never merely because a row carries a group column.
Prefer the exact subsidiary or operating account whenever it can be matched.
For an expressly requested broader search, an explicit, evidence-backed family,
brand-continuity, or network connection permits selecting a related platform
account as a distinct selection: `declared_scope` of `family` or `network`, with
`match_basis: parent_fallback`. For account discovery a clear family or network
connection is sufficient; a complete legal ownership chain or exact
legal-entity proof is not required, and no repeated per-row approval is needed
inside the authorized discovery workflow. Display the selected platform name
and its scope, for example `Matched — [platform account] (company-family/network
scope for [requested entity])`.

A family or network selection is valid when all of these hold:

- the user expressly requested a broader search beyond the named account (for
  example, group-wide opportunity discovery), so the related-account search is
  a requested step and not an implicit substitution;
- the requested entity genuinely could not be matched as an exact account after
  bounded recovery;
- a family, brand-continuity, or network connection between the submitted
  entity and the chosen platform account is established by corroborating
  evidence returned by the authorized platform tool for that account, or — only
  when the user has explicitly authorized external research — by an
  attributable authoritative company, brand, or network source with its URL and
  retrieval date, labelled external; and
- the chosen account is the platform account for that related entity, not a
  namesake.

Unverified sheet cells, conversation statements, notes, or other client-local
assertions may guide which query or candidate to examine, but they cannot by
themselves establish the connection, and a partner relationship observed
elsewhere does not establish it either. External corroboration is permitted
only under the user's explicit external-research authorization; keep it
separate, label it external, and cite its URL and retrieval date. It never
creates a Luasai graph fact and never authorizes a reveal, an access path, or a
relationship claim. Record the connection provenance (the returned platform
evidence, or the attributable authoritative source with its URL and retrieval
date) and the declared scope on the row.

This rule does not require the source name to equal the platform name, and it
does not require a full legal ownership chain or exact legal-entity proof. The
declared scope must be honest: a family or network connection is never reported
as `exact`, and the namesake and shared-domain safeguards below still apply.

Fallback still needs real evidence. Similar or shared brand names alone, or a
shared content domain alone, are not enough; a shared website is not proof of
subsidiary identity. Evidence-backed network scope does not assert legal
parenthood, so describe the actual connection rather than claiming a parent
relationship the profile does not establish. Do not trigger fallback merely
because a matched subsidiary has no partner relationships. An equally plausible
competing identity, or competing or conflicting family/network assertions
including a client assertion that disagrees with the returned evidence, requires
a bounded evidence resolution; if the conflict stays unresolved the row ends in
No match with that reason, while a retrieval or transport failure leaves it
incomplete instead.

Strict contract, CRM, and legal identity resolution keep their stricter
contract. This broader discovery fallback does not apply there, and it never
authorizes an invented relationship.

### Bulk discovery coverage is incomplete

A bulk discovery response covers at most the server's fixed candidate window; it
is a discovery aid, not a completeness claim. An empty, partial, or blocked bulk
response is never evidence that the account is absent and never justifies a
`No match`. A bulk `candidate_support.status` of `candidate_proposal` or
`recovery_required`, with `requires_caller_decision: true`, means the caller
must still decide the identity from the returned actual facts under the existing
positive gates; the server guard that inspects and clips the window before
returning candidates does not replace the caller's own source-context matching
and never authorizes an absence selection. Shortened names and omitted domain
or alias items are declared in `truncated_fields`; they cannot supply exact
identity proof. Read detail when the decision needs the missing full fact. A
full-window guard does not replace fresh canonical eligibility or source-context
gates.

Bulk coverage is incomplete by construction: a bulk row has no guaranteed
operating name, no hint seed, and no semantic arm, so a bulk miss is never
exhaustive and never selects a `No match`, and a bulk pass never reports global
exhaustive coverage as true. The full known-window counters describe only the
window that was actually inspected, never the whole population, and the caller
audits only the returned actual facts and any prior copies, keeping the
mandatory guard, the audit, and the existing thresholds unloosened.

A `bulk` alternate query is `name_variant` only; it never carries an implicit
family or network fallback, and a supplied parent or group column remains its own
ordinary row with no implied family connection.

The opt-in `bulk_semantic` lane is the same bounded compact single pass for at
most 20 rows, and it additionally executes the semantic lexical/vector/hybrid
arms and, only for a row whose own typed clues supplied them, the domain and
alias hint-seed arms. It still does not execute the operating-name projection or
the fuzzy similar/prefix coverage, so its coverage is incomplete by construction
too: an empty, partial, or failed `bulk_semantic` response is never by itself an
absence and never on its own selects a `No match`, and a `bulk_semantic`
shortlist is a bounded retrieval lead, not a match or an absence proof. The
server's own coverage receipt already enumerates the uncovered arms; do not
invent additional arm names. A `bulk_semantic` row still completes only through
the existing finite per-row recovery and decisive-ambiguity decision. Because the
lane hard-gates before the search POST on an explicit principal binding, a
positively advertised discovery-retrieval method, and a confirmed v2
identity-evidence producer — an authenticated readiness advertisement may be
sent first, before those gates pass — a missing method, a non-positive or
malformed advertisement, a withdrawn v2 producer, a transport failure, a
malformed, foreign, or incoherent response, or another whole-batch refusal comes
back as the generic retryable `candidate_search_unavailable` and fails every
attempted row of that call: it is an execution failure to retry, never a silent
lexical downgrade into a different mode, never an identity `No match`, and never
a hidden legacy-mode fallback. The top-level response carries an
`identity_evidence_availability` receipt only when genuine explicit-v2 tokens
were actually issued for returned usable candidates; a response with no usable
candidate omits that response-level receipt rather than claiming an unavailable
or legacy status, and a `bulk_semantic` miss is never on its own a `No match`.
Each returned usable candidate carries its own token.

## Mandatory candidate audit

Before freezing any selection or No-match for a physical row, scan every
candidate on every page already retrieved, not only rank one or the last page.
Create a short `strong_candidate_audit` entry for each candidate that meets any
of these conditions:

- normalized candidate name, legal name, or grounded alias equals the
  submitted name after ordinary legal suffix removal;
- the complete distinctive submitted token sequence remains intact and the
  candidate adds only ordinary corporate scope or legal terms, with returned
  profile corroboration;
- a grounded alias contains the complete distinctive submitted name; or
- an acronym or parenthetical expansion contains the complete distinctive
  submitted name.

When the submitted value is a shortened or ambiguous initialism and the full
source cell's annotations stay unexplained, also flag an actually inspected
distinct candidate that is a plausible same-core-brand or same-initialism rival,
even when it lacks the shortened bare alias or does not independently pass an
ordinary exact-name or alias gate, and keep it in the ambiguity or contradiction
review instead of dropping it for that reason.

First group repeated appearances by stable organization ID. A profile that
returns in fast or semantic mode, on more than one inspected page, or through a
different original, derived, or alternate query is one candidate for that
physical row, not evidence of multiple entities. Retain all occurrence paths and
merge only non-conflicting returned fields for its audit entry, and inspect
every returned copy for new or conflicting identity facts. When a copy adds no
new or conflicting identity fact, reuse the candidate's existing audit entry
instead of repeating the full reasoning or writing a duplicate entry; when it
does, reassess that candidate and the accumulated pool's uniqueness and
contradictions, since a newly eligible distinct ID can invalidate an earlier
provisional selection. A material identity-field conflict between copies does
not disappear through deduplication: the candidate cannot be selected unless an
explicit returned authoritative field reconciles the copies. If it is the only
positive-gate candidate, record the conflicting fields and continue into bounded
recovery instead of preferring the more complete copy.

For each distinct flagged candidate, record the candidate ID, page, rank,
actual returned fields supporting the assessment, any missing positive gate,
and any explicit returned-field contradiction. For a plausible rival under the
annotated-initialism rule above, record its own identity/business facts and the
unexplained source annotation; do not invent positive evidence. It can leave
source-context ambiguity unresolved without itself passing a positive gate,
and is not thereby an eligible account or an identity match.

Collect every candidate that passes a positive gate after the complete
different-entity contradiction review. Shared brand token overlap alone is not
a positive gate. Select only when exactly one candidate remains, or when the
source-context comparison in "Commercial eligibility and the country-context
tie breaker" above uniquely resolves one eligible candidate, and no unresolved
source-context ambiguity remains. A country tie breaker among eligible accounts
cannot bypass that ambiguity. Rank and retrieval score cannot break a tie. Apply that comparison before bounded recovery or any optional
read. If two or more eligible candidates remain and the returned facts already
show the choice turns only on client intent, complete the row as an ambiguity
**No match** before the optional read, naming the actual missing discriminator
privately and never substituting an arbitrary ambiguity label; a read cannot
invent client intent. Continue into bounded recovery, or use the optional read,
only when a genuinely missing candidate fact could change eligibility or
uniqueness; `account-list-workflow.md` carries the read-failure bounds. Do not
invent a contradiction to force a choice, and do not leave the rationale as a
blank statement such as "no unique defensible identity".

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

Keep the following material contradictions in scope during the audit and
recovery:

- the displayed name denotes a different company or public body, or a legal
  name does so with corroboration in the candidate's own name, domain, business,
  or hierarchy (an isolated, uncorroborated legal-surface value is an internal
  field-qualified data-health contradiction, not a selection blocker);
- primary or verified domain belongs to a different organization;
- description identifies a materially different institution or business;
- industry or sector makes the name similarity coincidental;
- the candidate is the wrong parent, subsidiary, or regional operating entity;
  or
- an explicit headquarters fact conflicts with the intended legal entity (a
  candidate's own headquarters in a different country than the supplied locating
  context is not by itself such a conflict); or
- the candidate belongs to a different entity namespace or kind than the source
  asks for, for example a national or government body where a commercial
  company is requested.

Geography settles a tie only under the country-context rule above; a matching
Market cannot rescue a candidate with a conflicting name, domain, description,
industry, or hierarchy, and a missing or unknown rival geography neither
conflicts nor proves absence. A role such as partner, reseller, account,
customer, or software company is descriptive rather than mutually exclusive.

Record a concise rationale naming the strongest positive evidence and the
material contradictions checked. For a no-match, also retain every inspected
mode/page, the `strong_candidate_audit` entries, and the bounded recovery record
described in `account-list-workflow.md`. Do not write hidden model confidence
as if it were a Luasai score.

## Bounded recovery

Internal uncertainty is resolved with a finite per-row recovery budget, not a
terminal review state. The authoritative budget lives in
`account-list-workflow.md`: the original query plus bounded derived query
variants, the per-mode page limits, the rich-detail and identity-read allowance,
the two-in-flight transport bound, and the recovery record are all defined there;
apply them there rather than restating them. The per-tool call caps are MCP call
limits rather than a per-row recovery allowance: a fast call carries at most 25
rows and a semantic or rich call at most five rows. Larger compact pages,
server-capability checks and the total candidate-slot budget are defined in
`account-list-workflow.md`; they change retrieval coverage per call, never
identity eligibility. A meaningful kind or modifier conflict still blocks, while an existing grounded commercial brand or trading
continuity can still identify the caller's own requested account without a
literal qualifier alias, judged from the candidate's own returned evidence.

Every zero-hit physical row carries an explicit recovery record: the attempted
variants, the evidence checks, the fallback attempts or a reason they were
inapplicable, and the final execution/outcome state. Recovery ends when a
defensible identity is selected or the finite per-row budget is exhausted with
only irrelevant candidates; a retrieval, transport, authorization, or
client-state error instead leaves the run incomplete until the failed work is
retried.

## Source policy

The default workflow is Luasai-only:

- organization and relationship facts come from the authenticated Luasai MCP;
- accepted partner opportunities come only from authorized Luasai platform
  relationship records with a qualified type and direction; web-only partner
  claims, cleanroom queries, and raw internal source URLs are never eligible;
- spreadsheet cells and conversation context may guide client-side selection
  but do not become Luasai graph facts;
- repository files, direct database queries, generic web search, and other
  connectors must not silently fill a Luasai gap; and
- if the user explicitly requests external research, keep it in separate
  source-labeled columns or a separate section with URL and retrieval date.

Never present external research as a Luasai relationship. A blank caused by
missing Luasai evidence remains blank in the Luasai column. Client decision
receipts are client-side audit artifacts; they are not MCP tool arguments and
not customer-facing output.

## Identity-detail read is working data

When the client advertises `luasai_graph_organization_identity_evidence`, one
candidate's omitted public identity evidence may be read with only the
candidate-issued `identity_evidence_token` — never an arbitrary organization id,
query, offset, or page. That read is internal resolver/agent working data used
only to make the client's own identity decision: the company identity facts in
it are the facts needed to decide, but it is not a source report, an audit
surface, or a customer deliverable.

The customer-facing result stays the matched platform account and its meaningful
scope, or a no-match reason. Do not add source references, citations, content
digests, capability tokens, or diagnostic receipts to customer output, and do
not build a user-visible evidence packet, source report, or audit tab by
default. A client decision receipt, the identity-evidence token, and any
diagnostic stay private operator/client working state, exactly as receipts
already do. The raw client tool protocol is not claimed to be technically
invisible: the boundary is what is presented to the customer, not a guarantee
about transport. A needed identity read that fails or stays unavailable leaves
the row incomplete, never an inferred no-match; its token rules, its exact
failure handling for a missing, rejected, changed, version-mismatched, or
transport-failed read, and its shared two-read rich-detail allowance are defined
in `account-list-workflow.md`.

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
