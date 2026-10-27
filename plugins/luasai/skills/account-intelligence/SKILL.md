---
name: account-intelligence
description: Populate or reconcile a spreadsheet, CSV, CRM export, or pasted account list with governed Luasai organization profiles and partner relationships. Use for multi-row account intelligence and writeback; not for one-company graph questions, internal data ingestion, or canonical data repair.
metadata:
  short-description: Enrich account lists with Luasai intelligence
  version: "0.3.20"
---

## Shared account recommendation precedence

When `luasai_graph_recommend_accounts` is advertised, use it for the identity stage instead of client-owned candidate selection in the references below. Send every physical row's stable `input_id` and exact supplied `name` with only that row's own supplied `known_domains`/`aliases`; an actual headquarters clue only as `hq_country`; and an actual supplied billing or source country as `source_country` only when the advertised schema publishes that field. Normalize every supplied country literal to a supported ISO2 code (`UK` → `GB`) and never infer a country from the account, a candidate, the workspace, or the market — market is not HQ, and `source_country` is soft billing/source location only, never a headquarters claim or a retrieval hint. An explicitly supplied additional or parent account is its own ordinary lookup with its own clues: never inherit the child row's country and never expand the family. Send at most 20 rows per call, at most two in flight. Trust the authoritative matched canonical `organization_id`; a completed `no_match` is bounded, while `execution_incomplete` is never a No match — retry it within the existing bounds and report the row pending or errored when it still does not complete. Do not silently replace a recommendation with a candidate or parent, and start no open-ended research. Retain the decision id and reason. Then use the existing relationship/reveal/writeback stage. Existing candidate-only workflows remain available when this capability is absent or an operator explicitly investigates. This paragraph takes precedence over their client-selection instructions.

# Luasai Account Intelligence

Use the Luasai MCP, and — only when an artifact is actually processed or
written — the customer's approved file or spreadsheet capability. The Luasai
tools supply governed organization and relationship intelligence; the client
agent selects identities, applies the user's partner criteria, and writes the
client-owned artifact when a written output is requested.

This Skill is instructions and references only. It does not contain a Luasai
client, credentials, executable, hook, or local MCP server. For multi-row
discovery every successfully completed row ends in exactly one state: **Matched
— [platform account] [scope]**, or **No match — [reason]**. There is no terminal
review state. A transport, authorization, upstream, or client-state failure
takes precedence and stays incomplete; it is excluded from the completed totals,
and the run is not complete until it is recovered.

## Stages

Load only the stage you are executing, so a single-identity lookup stays small.

1. **Identity stage (default).** Every account lookup begins here. Read and
   follow
   [references/bounded-account-list-workflow.md](references/bounded-account-list-workflow.md)
   before you make any Luasai candidate or identity-lookup tool call — not
   merely before choosing an organization. It is the complete default identity
   reference: the physical-cell and stable-`input_id` rules, the typed-clue and
   `alternate_query` rules, the one bounded preparation call and its fixed
   limits, the one-batch own-ID-or-abstain selection, the single targeted detail
   round, the source/tenant/identity boundaries, the binary outcomes, and the
   execution-incomplete split all live there. Freeze one platform account ID or
   one no-match per physical row before any later stage. If this module cannot
   be loaded, the identity work stays incomplete and is never a No match.
2. **Relationship, reveal, and writeback stage (only when requested).** When the
   user has actually asked for partner relationships, a paid reveal, or a
   written output, additionally read and follow
   [references/relationship-writeback-stage.md](references/relationship-writeback-stage.md).
   An identity-only lookup does not read it.

The longer identity files (`account-list-workflow.md` and
`identity-and-source-boundaries.md`) are operator-only. They document the
explicit lower-level `luasai_graph_organization_candidates` investigation and
its bulk/semantic recovery; they are not part of the normal default load.

## Required capabilities

Load only the capabilities the operation you are performing actually needs.

- **Identity preparation (identity stage, default).**
  `luasai_graph_prepare_organization_choices` is the supported normal
  preparation operation and is required. Preflight it once per run; when it is
  missing, the identity work stays incomplete and never silently degrades into
  an open-ended candidate research loop.
  `luasai_graph_organization_candidates` is retained as the lower-level tool for
  an explicit operator investigation, not the normal research loop.
  `luasai_graph_organization_identity_evidence` is used only when the active
  client advertises it and a candidate's identity is genuinely unresolved or a
  needed fact is still omitted, as described below.
- **Opening, processing, or writing a file or spreadsheet.** The provider's
  approved native artifact workflow is required whenever a file or spreadsheet
  is opened, processed, or written — including identity-only sheet work. It is
  not required for a chat-only lookup.
- **Chat-only lookup.** A lookup answered from a pasted list with no file
  opened needs no artifact workflow.
- **Requested relationship retrieval.** `luasai_graph_search` is required only
  when the user requests partner relationships.
- **Saved relationships and reveal.** `luasai_graph_revealed_relationships` is
  used only when saved results may exist, and `luasai_graph_reveal` only for the
  relationships actually needed, after the server quote and the existing client
  approval flow.
- **Identity-results-only writeback.** Writing identity results needs the
  approved artifact workflow but not `luasai_graph_search`,
  `luasai_graph_revealed_relationships`, or `luasai_graph_reveal`.

`luasai_graph_report_data_issue` is an optional QA follow-up. If a capability an
operation actually needs is unavailable, complete only the supported work and
report the exact blocker. Do not replace Luasai with a database query,
repository data, or web research.

## Normal workflow (bounded preparation)

The supported normal path is short and lives in
`references/bounded-account-list-workflow.md`; read it in full before the first
tool call. In outline: read the source artifact once, preserving every tab and
physical ID; extract only the literal supplied clues into the row's typed
fields; preserve the original names; send a bounded source-grounded
`alternate_query` with basis `name_variant` only when a compound or overlong
cell needs it; submit at most 20 rows per call to
`luasai_graph_prepare_organization_choices`; select exactly one returned
`organization_id` or an abstention per physical row in a single batch from your
own facts and the source context, never treating the server's retrieval score
as confidence; spend at most one targeted detail round when a decision genuinely
needs one omitted identity fact; and keep an execution-incomplete row separate —
it is never a No match by default. The preparation returns a bounded shortlist
(at most three candidates per executed stage), never a full-corpus search or an
absence proof.

## Operator legacy path

The lower-level `luasai_graph_organization_candidates` whole-sheet bulk, per-row
fast, and batched semantic investigation — with its mode caps, page limits, and
per-row recovery budget — is documented in the operator-only
`account-list-workflow.md`. Use it only when an operator deliberately needs that
hands-on inspection. The normal path above submits each physical row once to
the preparation operation, which runs the same bounded retrieval and recovery
internally.

## Optional identity-detail read

When the active client advertises `luasai_graph_organization_identity_evidence`
and one candidate's identity is genuinely unresolved, or a needed identity fact
is still omitted from the returned profile, you may read that one candidate's
omitted public identity evidence by passing back only the
`identity_evidence_token` returned on that candidate row. The tool accepts no
arbitrary organization id, query, offset, or page: the token pins one
organization and the requesting principal, tenant, and authentication type,
expires within ten minutes, and cannot be refreshed. Use it only for that one
decision, never to pre-fetch or page evidence for rows you can already decide.
One physical row's legacy rich-detail requests and its identity-detail reads
share the same two-read allowance, and every read shares the same at-most-two
calls in flight. A missing, rejected, changed, or failed necessary read is an
incomplete execution, never a no-match. This read is internal resolver/agent
working data: the customer-facing result stays the matched platform account and
its meaningful scope, or a no-match reason, and sources, citations, content
digests, capability tokens, and diagnostic receipts are never added to customer
output or shown as an evidence packet, source report, or audit tab.

## Non-negotiable boundaries

The identity guide states the identity rules in full. The entry-level points
this router must itself carry are:

- Preflight only the capabilities the operation needs. The preparation tool is
  required for the normal identity lookup; the candidate tool is required only
  for an explicitly requested operator investigation. Whenever a file or
  spreadsheet is opened, processed, or written — including an identity-only
  sheet pass — preflight and use the provider's approved native artifact
  workflow, and stop before retrieving organization data if a needed capability
  is missing. A chat-only lookup answered from a pasted list needs no artifact
  workflow. Load and use the provider's approved spreadsheet or file workflow
  before authoring; when a native artifact runtime is mandated, do not
  substitute a generic library.
- Keep the complete row and conversation context in the client agent, and send
  only the typed hints published by the candidate tool. Assign a stable
  physical-row ID to every requested cell before calling Luasai; a supplied
  parent, group, or other column value is its own ordinary lookup with its own
  `input_id`, never a special parent mode and never an ownership fact.
- Never call or recreate the internal `/publicv2/ai/orgs/resolve/batch` lane;
  candidate search is the interactive identity-discovery path. Never treat
  organization roles as exclusive.
- When an artifact is processed or written, use only the file, spreadsheet, and
  application capabilities approved in the customer's Claude workspace. Do not
  install a local helper, execute bundled code, or move the source artifact to
  an unapproved service. If Claude cannot safely preserve and reread the
  requested format, stop at preflight and state the missing capability. Visual
  inspection requires actually opening the rendered output, not inferring
  quality from a successful save.
- For requested artifact delivery, never claim completion from a tool trace
  or draft workbook alone. Delivery requires saved-artifact reread, row
  reconciliation, rendered-image review, and repair followed by a second
  render and review when any visual defect is found. A chat-only identity
  lookup completes with reconciled physical-row decisions and private client
  decision receipts; it does not create an artifact.
