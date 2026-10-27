# Relationship, reveal, and writeback stage

Load this module only after the identity stage is frozen for the rows it covers
and the user has actually requested partner relationships, a paid reveal, or a
written output. An identity-only lookup does not read this file.

Identity is frozen per physical row and per settled batch, not once for the whole
workbook: this later stage may run for already-frozen rows while other rows are
still unresolved or incomplete. It adds no research, no second recovery pass and
no retry of its own beyond the identity rules already approved for those rows. The
identity-stage state machine, the candidate budget, and the client decision
receipts live in `account-list-workflow.md` and
`identity-and-source-boundaries.md`; keep the frozen per-row identity from that
stage and never revise it because a later relationship result is more
commercially convenient.

## Required capabilities for this stage

Preflight each operation, not the whole module.

- `luasai_graph_search` is required only when the user has requested partner
  relationship retrieval.
- `luasai_graph_revealed_relationships` is used only when saved results may
  exist, and `luasai_graph_reveal` only for the relationships actually needed,
  after the server quote and the existing client approval flow.
- The provider's approved artifact workflow is required only when a file or
  spreadsheet is opened, processed, or written.
- Writing identity results only — with no relationship retrieval — needs the
  approved artifact workflow and none of these relationship tools.

`luasai_graph_prepare_organization_choices` is the normal identity-stage
preparation step; the lower-level `luasai_graph_organization_candidates` stays
available for an explicit operator investigation. Neither is a relationship
tool. A missing capability an operation actually needs is a clean preflight
failure, and it never relaxes the identity decision already frozen.

## 4. Retrieve relationships

First scope `luasai_graph_revealed_relationships` to the selected subject
organization IDs when saved results may satisfy the request. Viewing saved
results uses no credits.

Then use `luasai_graph_search` with `account_input_refs`, preserving the exact
physical-row IDs. Apply only the user's criteria:

- a general account-to-reseller request uses `relationship_type:
  reseller_account`;
- a request such as “Snowflake partner” requires reseller-account relationships
  whose reseller is independently linked to the named software company, using
  the tool's published `required_reseller_isv_terms`; and
- a reseller-to-software-company question uses `relationship_type:
  reseller_isv` and its required `isv_terms`.

Do not infer a software partnership from an existing spreadsheet value, email,
company description, or reseller name. Follow relationship pagination when
later results could change the requested cell. Preserve whole-result per-row
counts so a current empty page is not mistaken for a relationship gap. Accepted
partner opportunities come only from authorized Luasai platform relationship
records with a qualified type and direction; a web-only partner claim, cleanroom
query, or raw internal source URL is never eligible.

Partner cardinality belongs to the user, not the model. If the request states a
count, ranking rule, or selection criterion, apply it deterministically. If it
does not, deduplicate by relationship organization ID and write every
qualifying named relationship from the complete paginated result set in stable
server order. A singular column label or the word “significant” does not imply
“top three.” A top-three presentation is a display choice the user may request;
it is never treated as complete coverage. When the destination cell cannot
safely hold the complete set, write the complete stable-order set in the
requested audit/detail destination, and make the source summary cell's
truncation, total count, and a working link (or clearly stated continuation
path) to the overflow explicit. Never silently discard names.

When an exactly matched subsidiary has no usable partner evidence, broader
company-family, parent, network, or regional discovery is a separate,
user-requested step, authorized inside the same bounded budget only when the
user has expressly asked for a search beyond the named account (for example,
group-wide opportunity discovery) and never merely because a row carries a
group column, without a new per-row
approval and without replacing the selected subsidiary identity. Send that
related-account search as the row's `alternate_query` with basis
`family_network`: the alternate string is only a retrieval lead for finding the
related platform account, and the matched subsidiary identity stays selected.
Return additional opportunities under the actual related account and its
declared scope. Every returned partner opportunity must
be a qualified platform relationship on that actual related platform account,
under the existing access, authorization, and reveal rules, and must never be
attributed to the specific subsidiary. Reserve "warm", "current", or "local
introduction" language for published evidence that supports it.

For equivalent duplicate rows that select the same organization and use the
same criteria, apply the same partner-selection policy. Preserve their separate
reconciliation receipts.

## 5. Quote and reveal

Graph search is free and returns a server quote. Determine which relationship
keys are actually needed for the requested named output. Before the first paid
action, report the exact quote through the active client approval flow. A clear
identity or family/network selection made inside the authorized discovery
workflow does not add a fresh approval; the existing reveal-approval rules are
unchanged.

Call `luasai_graph_reveal` only for needed keys from the current quote. Use a
stable task-scoped idempotency key. Trust the server-returned charge, newly
revealed count, already-revealed count, and remaining balance; never estimate
them. Reopening an entitlement is not a new reveal. Respect the per-tool
budgets, page limits, and reveal permissions already published by the server.

If reveal is unavailable or not approved, retain the row as
`qualifying_relationship_unrevealed` rather than converting a masked preview
into a named partner.

## 6. Write and reread

Write only the requested output cells and any explicitly requested audit sheet.
Use the provider-native artifact workflow already approved for this task and
preserve source values, physical-row order, duplicate rows, sheet names,
formulas, hyperlinks, validations, styles, and unrelated columns.

Writeback may proceed for the rows that are already frozen while other rows are
still unresolved; a row whose identity is not frozen is never written as a
completed result, and the run stays incomplete until that row is recovered.

Every row must end with one identity status (a completed `Matched`/`No match`,
or an explicit not-completed failure state), one relationship status, one
writeback status, and a truthful reason for each blank. A failed row never
carries a completed identity status. Keep these terminal states distinct:

- identity no-match with its reason;
- selected organization with no qualifying Luasai relationship;
- qualifying relationship present but unrevealed;
- MCP or reveal failure;
- value chosen but not written; and
- value written and reread successfully.

After saving, reopen the artifact and verify:

- physical row count, order, tabs, and preserved source values;
- source columns, formulas, and existing hyperlinks;
- every requested output cell, including the actual target of any summary link;
- every blank reason;
- formula-error scan;
- overflow and continuation cells, including the linked target for any
  truncated partner list; and
- reveal receipts against the server response and wallet delta.

A tool success or a successful write call is not delivery completion. Reread
the persisted values and hyperlinks after saving; only the reread supports a
completion claim.

Rendering is not visual inspection. Open every rendered sheet image with the
active client's native image-view capability and inspect it. A PDF page count,
file existence check, text extraction, or command exit code cannot support a
claim that the workbook was visually inspected. Treat clipping, overflow across
row or column boundaries, and collisions with other values as failed
completion. Repair the workbook, rerender every affected sheet, and open the
repaired images before reporting completion.

When a complete partner list cannot fit readably in the source layout, keep the
complete stable-order set in the audit or detail sheet and replace only the
source summary cell with the first three names, the truncated count, and a
working link (or clearly stated continuation) to the overflow. This is an
explicit presentation summary, not a top-three result limit: counts, status,
and the audit row must still describe the complete qualifying set.

Report rows processed, matched, no-match, populated, explicit relationship
gaps, MCP failures, semantic follow-ups, candidate and relationship pagination,
credits charged and remaining, and saved-artifact reread status. Do not claim
ground-truth match accuracy without a separately adjudicated identity ledger.
