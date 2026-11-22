---
name: system-design
description: "Use only when your human partner explicitly asks for it (/system-design) to work through a system design question: designing a system, comparing architectures, or reasoning about scale and trade-offs. Not part of the normal build process; never trigger it on your own."
disable-model-invocation: true
---

# System Design

Your human partner called this because they want to think through a
system's design. Your job is to reason about it with them, not to build
anything. A good answer shows the trade-offs and the numbers behind each
choice, so they can see why and disagree.

This skill is a method. The knowledge comes from you and from the
reference library below.

## Look Before You Ask

If the question is about a real system (their codebase, their database,
their infrastructure), read it first: the code, the schema, the config,
whatever tools this session has. Never ask what you can look up. Only they
can say the scale they expect, what matters most, and what they can
afford.

If the question is open ("design a chat app"), ask at most one or two
questions, and only if the answer would change the design. Otherwise say
your assumptions in a line each and go. They can correct an assumption
faster than they can answer a questionnaire.

## The Reference Library

`system-design-101/` at the root of this repository (two levels up from this
file: `../../system-design-101/`) is a git submodule of ByteByteGo's
system-design-101: about 400 short guides, each a diagram plus a few
paragraphs. It is licensed CC BY-NC-ND and used here for personal reference
only. Never copy its text into a deliverable, a commit, or another skill.
Cite the guide by name instead.

If the directory is missing or empty, tell your human partner to run
`git submodule update --init system-design-101` from the repository root, and
work from what you know in the meantime. Don't pretend you consulted it.

How to use it:

- The guides are in `system-design-101/data/guides/`. Search by file name,
  `title`, `tags`, or `categories` in the frontmatter (for example
  `grep -il "sharding" system-design-101/data/guides/*.md`). The
  `data/categories/` files are only short blurbs, not indexes.
- Read the guides for the two or three decisions that matter most. Don't
  read broadly.
- Each guide's diagram is a remote image (the `image:` URL in its
  frontmatter), not a file in the repo. The text is a summary of it. Fetch
  the image only when the flow or layout is what you need, and say that you
  did.
- Say where each claim comes from: "from the guide on X" versus "my own
  reasoning". Don't present either as certain.

## The Method

Work through these in order. Skip a step only when the answer is already
known, and say so.

1. **Requirements.** What the system must do, in a few lines. Then what it
   must be: latency, availability, consistency, durability, and what a
   failure costs. Note what you are leaving out.
2. **Scale.** Back-of-envelope: users, requests per second (average and
   peak), read/write ratio, storage per year, bandwidth. Show the
   arithmetic and mark every input as an assumption. The point is to learn
   which parts are hard, not to be precise.
3. **Shape.** The main components, the data flow between them, the API at
   the edges, and the core data model. One simple design first. Don't start
   with the final architecture.
4. **Deep dives.** Pick the two or three parts the numbers show are
   hardest. For each decision, give two or three options, what each costs
   and buys, your pick, and what would change it. A decision with one
   option listed isn't a decision.
5. **Failure.** Single points of failure, hot keys, retries and
   idempotency, back-pressure, partial outages, what degrades and what
   breaks. Say what happens when each piece dies.
6. **Growth.** What breaks at 10x, and the first thing you'd change.

## What You Hand Back

A design they can argue with: assumptions, numbers, the chosen shape, the
decisions with their trade-offs, the failure story, and what you are least
sure of. Use a diagram (Mermaid or ASCII) when it shows the flow better
than words. Keep it as short as the question allows. A small question gets
a short answer.

## Don't

- Don't give one "correct" architecture. Systems have trade-offs, and the
  right answer depends on the numbers and what they care about.
- Don't list every technology you know. Name the one you'd pick and why.
- Don't invent figures and state them as facts. Estimates are labeled.
- Don't add components the scale doesn't justify. A single database is
  often the right answer; say so when it is.
- Don't start building. If they decide to build it, hand the result to
  `superpowers:brainstorming` or `superpowers:writing-plans`, and stop
  there.
