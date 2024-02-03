# Contributing YAML booster files

This folder is a repository of different YAML files, which are compiled into sealed boosters.

## File naming convention

File names should follow the following formatting:

- `{set_code}.yaml` - draft booster
- `{set_code}-{variant}.yaml` - other variants
  - `{set_code}-arena.yaml` - arena booster
  - `{set_code}-set.yaml` - set booster
  - `{set_code}-collector.yaml` - collector booster
- All codes can be appended with `-jp` to indicate Japanese booster variants

If you are using a non-standard variant, you can add a `name:` parameter to the top of your file to indicate what the booster name should be. For example, the file `2xm-vip.yaml` includes the line:
`name: "Double Masters VIP Edition"`

## Contents

A booster YAML contains two core components: the `pack`, which lists what sheets constitute each slot of the booster; and the `sheets`, which detail which cards are available on each sheet. Here is a simple example file:

```yaml
# The top comment is where most information about the booster goes, including key
# assumptions, known information sources, or other relevant information

# Some packs include the name of the booster if it isn't in the standard variation types.
name: "Example Booster"

# The pack section defines what each slot in the booster can contain.
pack:
  basic: 1
  common: 9
  uncommon: 3
  rare_mythic_special: 1
  common_or_foil:
  - common: 1
    chance: 2
  - foil: 1
    chance: 1

# The sheets section defines what each sheet contains.
sheets:
  common:
    balanced: true
    query: "r:c"
  uncommon:
    query: "r:u"
  rare_mythic_special:
    any:
    - use: rare
      rate: 2
    - use: mythic
      rate: 1
    - use: special
      rate: 1
```

### Pack

`pack` is a mapping of sheet names to the number of times that slot appears. Sheets can be listed multiple times, or variable slots can create different booster variations.

#### Static slots

A static slot is written in the format `  {sheet_name}: {count}`, where `count` is the number of times that slot appears in the booster. For example, most draft boosters have `  uncommon: 3` to indicate that there are 3 slots that contain the contents of the `uncommon` sheet. The key for these mappings must match exactly to a sheet type.

#### Variable slots

Most boosters have some type of variation, whether that is the variable number of common/uncommon cards in a set booster, or an inserted foil in a draft booster. You can indicate the probability for these variable slots using the following syntax:

```yaml
  slot_name: # The slot name should not match an existing sheet
  - {sheet_1}: {count}
    chance: {chance}
  - {sheet_2}: {count}
    chance: {chance}
```

There are some useful features of variable slots:
- The total number of slots does not need to be consistent across all variations. Examples like [afr-set.yaml](afr-set.yaml) use this feature to add The List cards.
- Unlike sheets, variable slots can mix foil/non-foil cards. For slots that may or may not be foil, this is the proper way to indicate that variability.

The `chance` parameter correlates to the relative rarity of each version. So for common draft foils, which appear in 1/3 packs, the `common` sheet would have `chance: 2` and the `foil` sheet would have `chance: 1`. The total number of variations is 3, and 1 of those variations is the `foil` sheet.

### Sheets

`sheets` is a mapping that connects the sheet names to the cards that can appear on that sheet.

Sheets and subsheets can always include a `count` variable to assist in troubleshooting. This will warn the user if the number of cards returned by a query does not match the expected `count` value.

Parent sheets can also include a `foil` boolean to indicate if the sheet is foil. You cannot mix foil/non-foil cards in the same sheet. To achieve this, use a [Variable slot](#variable-slots)

#### Common sheets

Many sheets are predefined, and do not need to be specifically listed in the individual yaml files. You can see the list of common sheets in [common.yaml](common.yaml).

#### Query

Simple sheets can be defined using a `query` tag. These queries only return standard-frame, core set cards from the set listed in the file name, and use the same formatting for the mtg.wtf search bar.

Example from [war.yaml](war.yaml) that returns all core set uncommon planeswalkers:

```yaml
  planeswalker_uncommon:
    query: "t:planeswalker r:u"
    count: 20
```

#### Rawquery

More complex sheets cam use `rawquery` to find cards outside the limitations of the `query` tag. The formatting for `rawquery` still matches the formatting of the mtg.wtf search bar.

Example from [cmr-collector.yaml](cmr-collector.yaml) that returns uncommon rarity, etched frame legendary cards:

```yaml
  etched_uncommon:
    foil: true
    rawquery: "e:cmr frame:etched (r:u or r:s) -is:reprint"
```

#### Any

Sheets can use the `any` tag to combine different subsheets together. Each subsheet can use any sheet variation but cannot change the parent foil parameters. There are two types of `any` sheets: `rate` and `chance`. The two variations cannot be mixed in the same set of subsheets.

##### Rate

By defining the `rate` for each sheet, you define the relative rarity of each card independent of the number of cards. Rare cards are often twice as common as mythic cards in the same sheet, so you can use `rate: 2` for the rare cards, and `rate: 1` for the mythic cards.

Example from [dmu.yaml](dmu.yaml) to track the rare/mythic legendary cards:

```yaml
  legendary_rare_mythic:
    any:
    - query: 't:"legendary creature" r:r'
      rate: 2
    - query: 't:"legendary creature" r:m'
      rate: 1
```

##### Chance

By defining the `chance` for each sheet, you define the relative rarity of that subsheet as a whole. Each card within that sheet is adjusted to match the total chance. You can also use math expressions to determine the chance of a specific sheet.

Example from [tsr.yaml](tsr.yaml) to include the timeshifted cards in the foil sheet (the `use` parameter will be explained later):

```yaml
  foil:
    foil: true
    any:
    - use: rare_mythic
      chance: 1
    - query: "r:u"
      chance: 2
    - query: "r:c"
      chance: 4
    - query: "r:s"
      chance: 1
```

#### Use

Sheets can `use` a previously defined sheet to replicate all aspects of that sheet in a new context. Often this is used as a subsheet in a larger sheet, but can also replicate a previous query using new context.

Example from [afr.yaml](afr.yaml) to define the rare/mythic slot with showcase cards:

```yaml
  rare_mythic_with_showcase:
    any:
    - use: rare_with_showcase
      chance: 60 * 2
    - use: mythic_with_showcase
      chance: 20
```

It's best practice to avoid mixing `use` and `any-rate` because it can behave unintuitively. Better practice is to use either `query\rawquery` instead of `use`, or `any-chance` instead of `any-rate` when possible.

#### Filter

Filters can be applied to `query` and `use` subsheets to adjust their context.

Example from [2xm-vip.yaml](2xm-vip.yaml) to define the foil, borderless rare and mythic cards:

```yaml
  foil_rare_mythic_borderless:
    foil: true
    filter: "e:2xm is:borderless"
    use: rare_mythic
```

The filter can also be applied to an entire file by putting it at the top of the file, such as in [por.yaml](por.yaml)

#### Set/Code

Certain sets require specific lists of cards, which can be listed out manually using the `set` option. Set documents should be put into `data/print_sheets_new/*.txt` and named for the specific set the cards are from.

Set files use the following format (note a minimum of two spaces beween each section):

```
Card Name  Number  SheetCode
```

Spaces are allowed in the card name, which should exactly match the scryfall name. For multi-part cards, you should ONLY reference the primary part and number. So "Fire // Ice - DMR - 215" should be referenced as `Fire  215a  SheetCode`. A single card can have multiple sheet codes, separated by a single space. Sheet codes cannot have numbers, as numbers represent the relative rarities of each card within a sheet code.

To reference a sheet within the booster yaml, use `sheet` to reference which sheet document the cards are in, and `code` to determine which `SheetCode` to pull.

An example from [znr-set.yaml](znr-set.yaml) to define The List cards:

```yaml
  the_list:
    set: plst
    code: "ZNR"
```

#### Queries to avoid

Do not use `is:booster` or `booster:` in your queries, as they're calculated from booster data, so it will not be present yet during booster calculations.

All other queries are fine to use.

## Troubleshooting and Debugging

Once you've built a YAML file, the indexing tools need to be executed to properly incorporate that new booster into the program.

In order to load the booster into the `booster_index`, you should run

`> ruby ./booster_indexer/bin/booster_indexer`

*If you are modifying a set code* you will need to execute the following to load the new set sheet information into the main index:

`> ruby ./indexer/bin/indexer`

Once you have properly indexed the booster information, you can access it in multiple ways:

- Use `> ruby ./bin/human_export_sealed_data {temp folder}` to build all current boosters into the location specified by `{temp folder}`. Typically the folder `tmp/sealed` is used but ultimately that is up to you.
- To view the booster visually in the Rails frontend, use the instructions in the top level ReadMe to build and load the frontend. Then you can navigate to `http://localhost:3000/pack/{pack-code}` to view the results in HTML.

## YAML style guide

Full information about the YAML language can be found [here](https://yaml.org/spec/1.2.2/). Style guide is adapted from the [Home Assistant YAML style guide](https://developers.home-assistant.io/docs/documenting/yaml-style-guide/)

For the purposes of this repository:

### Indentation

Use indentation of two spaces

```yaml
# Good
pack:
  common: 1

# Bad
pack:
    common: 1

pack:
	common: 1 # do not use tabs
```

### Booleans

We should avoid the use of truthy boolean values in YAML. They often throw off people new to YAML. Therefore, we only allow the use of true and false as boolean values, in lower case.

This keeps it compatible with the YAML 1.2 specifications as well, since that version dropped support for several unquoted truthy booleans (e.g., y, n, yes, no, on, off and similar).

```yaml
# Good
one: true
two: false

# Bad
one: True
two: on
three: yes
```

### Comments

Adding comments to blocks of YAML can really help the reader understand the example better.

The indentation level of the comment must match the current indentation level. Preferably the comment is written above the line the comment applies to, otherwise lines may become hard to read on smaller displays.

Comments should start with a capital letter and have a space between the comment hash # and the start of the comment.

```yaml
# Good
example:
  # Comment
  one: true

# Acceptable, but prefer the above
example:
  one: true # Comment

# Bad
example:
# Comment
  one: false
  #Comment
  two: false
  # comment
  three: false
```

### Sequences

Sequences should be block style and should maintain the previous level of indentation. Nested sequences should increment 1 indentation level.

```yaml
# Good
example:
- a:
  - 1
  - 2
- b:
  - 1
  - 2

# Bad
example:
  - a:
   - 1
   - 2
  - b: [1, 2]
```

### Mappings

Mappings can be written in different styles, however, we only allow the use of block style mappings. Flow style (that looks like JSON) is not allowed.

```yaml
# Good
example:
  one: 1
  two: 2

# Bad
example: { one: 1, two: 2 }
```

### Strings

Strings are preferably quoted with double quotes.

```yaml
# Good
example: "Hi there!"

# Avoid
example: Hi there!

# Bad
example: 'Hi there!'
```
