import { tool } from "@opencode-ai/plugin"

/** Arguments for the ast-grep tool */
interface AstGrepArgs {
  pattern: string
  rewrite?: string
  lang?: string
  path?: string
  json?: boolean
}

/** Context passed to tool execute function */
interface ToolContext {
  agent?: string
  tools?: Record<string, boolean>
}

/**
 * Checks if the current agent has edit permissions
 * @param ctx - Tool execution context
 * @returns true if edit is enabled, false otherwise
 */
function hasEditPermission(ctx?: ToolContext): boolean {
  return ctx?.tools?.edit === true
}

/**
 * Generates the tool description based on available permissions
 * When edit is disabled, rewrite functionality is not mentioned
 */
const SEARCH_DESCRIPTION = `Search code using ast-grep for structural pattern matching based on AST (Abstract Syntax Tree).

WHEN TO USE THIS TOOL vs GREP:
- Use ast-grep when searching for CODE STRUCTURES (functions, classes, patterns, control flow)
- Use grep when searching for LITERAL TEXT (strings, comments, identifiers by exact name)
- ast-grep understands syntax; grep only sees text

METAVARIABLE SYNTAX:
- $NAME: Matches a single AST node (identifier, expression, etc.)
- $$$: Matches zero or more nodes (arguments, statements, etc.)
- $_: Matches any single node (wildcard, not captured)

PATTERN EXAMPLES BY LANGUAGE:

TypeScript/JavaScript:
- Function calls: "console.log($$$)" or "fetch($URL, $$$)"
- Arrow functions: "($$$) => $BODY" or "async ($$$) => $BODY"
- Imports: "import { $$$ } from '$MODULE'"
- React hooks: "useState($INIT)" or "useEffect($$$)"
- Async/await: "await $EXPR"
- Try-catch: "try { $$$ } catch ($ERR) { $$$ }"

Python:
- Function defs: "def $NAME($$$): $$$"
- Class defs: "class $NAME($$$): $$$"
- Decorators: "@$DECORATOR"
- With statements: "with $EXPR as $VAR: $$$"
- List comprehensions: "[$EXPR for $VAR in $ITER]"

Rust:
- Function defs: "fn $NAME($$$) -> $RET { $$$ }"
- Match expressions: "match $EXPR { $$$ }"
- Unwrap calls: "$EXPR.unwrap()"
- Result handling: "$EXPR?"

Go:
- Function defs: "func $NAME($$$) $RET { $$$ }"
- Error checks: "if err != nil { $$$ }"
- Goroutines: "go $FUNC($$$)"

MULTI-LINE PATTERNS:
- Patterns can span multiple lines for matching code blocks
- Use $$$ to match variable numbers of statements within blocks
- Example - find if statements with early return:
  pattern="if ($COND) {
    return $VAL
  }"
- Example - find try-catch blocks:
  pattern="try {
    $$$BODY
  } catch ($ERR) {
    $$$HANDLER
  }"

CRITICAL LIMITATION - SINGLE AST NODE:
- A pattern MUST parse to exactly ONE AST node
- "Multiple AST nodes detected" error means your pattern has separate syntax elements
- WRONG: "#[attr] pub $NAME: $TYPE" (attribute + field = 2 nodes)
- RIGHT: "pub $NAME: $TYPE" (just the field = 1 node)
- WRONG: "import $A; import $B" (2 import statements)
- RIGHT: "import $A" (1 import statement)
- For multi-node matching, use YAML rules with relational rules (has/inside) instead

TIPS:
- Patterns must be syntactically valid in the target language
- Use --lang when the file extension is ambiguous or when searching mixed codebases
- Start with simpler patterns and refine; overly specific patterns may miss variants
- Use --json for structured output when parsing results programmatically`

const REWRITE_ADDENDUM = `

REWRITE MODE (requires edit permission):
- Use the 'rewrite' parameter to perform AST-based code transformations
- Rewrites are applied in-place to matching files
- Metavariables captured in pattern are available in rewrite template
- Example: pattern="console.log($MSG)" rewrite="logger.debug($MSG)"

REWRITE EXAMPLES:
- Rename function: pattern="oldFunc($$$)" rewrite="newFunc($$$)"
- Add error handling: pattern="$EXPR.unwrap()" rewrite="$EXPR.expect(\"error\")"
- Modernize syntax: pattern="var $X = $Y" rewrite="const $X = $Y"

MULTI-LINE REWRITE EXAMPLES:
- Wrap function body with error handling:
  pattern="function $NAME($$$ARGS) {
    $$$BODY
  }"
  rewrite="function $NAME($$$ARGS) {
    try {
      $$$BODY
    } catch (err) {
      console.error(err)
      throw err
    }
  }"
- Convert callback to async/await:
  pattern="$FN($$$ARGS, function($ERR, $RESULT) {
    $$$BODY
  })"
  rewrite="const $RESULT = await $FN($$$ARGS)
  $$$BODY"
- Add logging to catch blocks:
  pattern="catch ($ERR) {
    $$$HANDLER
  }"
  rewrite="catch ($ERR) {
    logger.error($ERR)
    $$$HANDLER
  }"`

export default tool({
  description: SEARCH_DESCRIPTION + REWRITE_ADDENDUM,
  args: {
    pattern: tool.schema
      .string()
      .describe("The ast-grep pattern to search for (uses metavariables like $VAR, $$$)"),
    rewrite: tool.schema
      .string()
      .optional()
      .describe("Replacement pattern for matched code (requires edit permission). Use captured metavariables from pattern."),
    lang: tool.schema
      .string()
      .optional()
      .describe("Language to parse as (e.g., python, typescript, javascript, rust, go, java)"),
    path: tool.schema
      .string()
      .optional()
      .describe("Directory or file to search in (defaults to current directory)"),
    json: tool.schema
      .boolean()
      .optional()
      .describe("Output results as JSON for structured parsing (search mode only)"),
  },
  /**
   * Executes ast-grep pattern search or rewrite via Bun subprocess
   * @param args - Configuration for ast-grep execution
   * @param ctx - Tool execution context with agent permissions
   * @returns Search/rewrite results or error message
   */
  async execute(args: AstGrepArgs, ctx?: ToolContext) {
    const isRewriteMode = Boolean(args.rewrite)

    // Permission check for rewrite mode
    if (isRewriteMode && !hasEditPermission(ctx)) {
      return `Error: Rewrite mode requires edit permission, but this agent has edit disabled.

To perform AST-based rewrites, either:
1. Use an agent with edit:true permission
2. Switch to an agent like 'build' or 'general' that has edit enabled

Current operation cancelled to respect permission model.`
    }

    // Build command
    const cmd = ["ast-grep", "run", `--pattern=${args.pattern}`]

    if (args.lang) {
      cmd.push(`--lang=${args.lang}`)
    }

    if (isRewriteMode) {
      cmd.push(`--rewrite=${args.rewrite}`)
      // Apply changes in-place (no --json in rewrite mode)
    } else if (args.json) {
      cmd.push("--json=stream")
    }

    if (args.path) {
      cmd.push(args.path)
    }

    try {
      const proc = Bun.spawn(cmd, {
        stdout: "pipe",
        stderr: "pipe",
      })

      const stdout = await new Response(proc.stdout).text()
      const stderr = await new Response(proc.stderr).text()
      const exitCode = await proc.exited

      if (exitCode !== 0) {
        const errorMsg = stderr?.trim() || `Command failed with exit code ${exitCode}`
        return `Error: ${errorMsg}`
      }

      const result = stdout.trim()
      if (!result) {
        return isRewriteMode
          ? "No matches found. No files were modified."
          : "No matches found for the given pattern."
      }

      return isRewriteMode
        ? `Rewrite complete:\n${result}`
        : result
    } catch (error) {
      return `Failed to run ast-grep: ${error instanceof Error ? error.message : String(error)}`
    }
  },
})
