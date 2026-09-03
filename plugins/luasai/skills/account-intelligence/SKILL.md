---
name: account-intelligence
description: Populate or reconcile a spreadsheet, CSV, CRM export, or pasted account list with governed Luasai organization profiles and partner relationships. Use for multi-row account intelligence and writeback; not for one-company graph questions, internal data ingestion, or canonical data repair.
metadata:
  short-description: Enrich account lists with Luasai intelligence
  version: "0.2.0"
---

# Luasai Account Intelligence

Use the customer's approved file or spreadsheet capability together with the
Luasai MCP. The Luasai tools supply governed organization and relationship
intelligence; the client agent selects identities, applies the user's partner
criteria, and writes the client-owned artifact.

This Skill is instructions and references only. It does not contain a Luasai
client, credentials, executable, hook, or local MCP server.

## Required capabilities

The normal workflow requires:

- `luasai_graph_organization_candidates`;
- `luasai_graph_search`;
- `luasai_graph_revealed_relationships` when saved results may exist; and
- `luasai_graph_reveal` when the requested named result is not already
  available.

If a required tool is unavailable, complete only the supported stages and
report the exact blocker. Do not replace Luasai with a database query,
repository data, or web research. The public OAuth plugin does not expose the
API-key-only Luasai data-health writer.

## Method

1. Preflight the required Luasai tools and the provider's approved file or
   spreadsheet capability. If either is unavailable, stop before retrieving
   organization data and report the missing native capability.
2. Inspect the artifact and identify every physical account row, the user's
   requested output fields, partner criteria, and source policy. Assign a
   stable physical-row ID before calling Luasai. Load and use the current
   provider's approved spreadsheet or file workflow before authoring; when a
   native artifact runtime is mandated, do not substitute a generic library.
3. Read [references/account-list-workflow.md](references/account-list-workflow.md)
   and maintain its row ledger through candidate search, relationship search,
   reveal, writeback, and reread.
4. Read
   [references/identity-and-source-boundaries.md](references/identity-and-source-boundaries.md)
   before choosing any organization. Apply its fail-closed positive-evidence
   gate to every selected row; a semantically related profile without name,
   alias, or domain identity evidence must be rejected. Candidate rank and
   retrieval scores are ordering evidence, never a match decision. Before any
   abstention, run the reference's strong-candidate audit across every returned
   profile and inspected page. Deduplicate repeated appearances by stable
   organization ID before evaluating multiplicity. Select only when exactly one
   distinct candidate passes a positive identity gate without contradiction,
   or when explicit row context and returned fields uniquely disambiguate it.
   If multiple distinct profiles remain defensible, abstain and record their
   IDs plus the missing discriminator.
5. Select one defensible organization per row or abstain. Freeze the identity
   ledger before graph search. Do not ask Luasai to make the client-side
   contextual decision.
6. Apply only the user's partner criteria. Search is free; reveal only the
   relationships needed for the requested output, after reporting the server's
   quote through the active client approval flow. Do not invent a top-N cap:
   when the user supplies no cardinality limit, return every qualifying named
   relationship from the completed result set.
7. Write with Claude's approved file or spreadsheet capability, then reread, render,
   visually inspect, and reconcile every physical row. Repair every clipped,
   overflowing, or colliding source cell before completion. If the full
   partner set cannot be readable in the source layout, write a deterministic
   summary such as the first three stable-order names plus
   `(+N more; see MCP Evaluation)` and retain the complete set in the audit or
   detail sheet. A blank with a truthful terminal reason is complete; an
   unprocessed or unwritten row is not.

## Non-negotiable boundaries

- Keep the complete row and conversation context in the client agent. Send
  only the typed hints published by the candidate tool.
- Treat Market or sales territory as a selection clue, not headquarters or a
  stored company fact.
- Use Luasai only by default. External research requires an explicit user
  request and separate source-labeled output.
- Never call or recreate internal Luasai resolver routes. Candidate search is
  the interactive identity-discovery path. The optional
  formal MCP resolver is read-only and is not a fallback after the client has
  already made a defensible candidate choice.
- Never treat organization roles as exclusive. An account may also be a
  partner, reseller, or software company.
- Keep at most two candidate calls in flight. Never repeat a successful
  candidate request with the same row ID, name, hints, mode, and page.
- Use only the file, spreadsheet, and application capabilities approved in the
  customer's Claude workspace. Do not install a local helper, execute bundled
  code, or move the source artifact to an unapproved service. If Claude cannot
  safely preserve and reread the requested format, stop at preflight and state
  the missing capability. Visual inspection requires actually opening the
  rendered output, not inferring quality from a successful save.
- Never claim completion from a tool trace or draft workbook alone. Completion
  requires saved-artifact reread, row reconciliation, rendered-image review,
  and repair followed by a second render and review when any visual defect is
  found.
