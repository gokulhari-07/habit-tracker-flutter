import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._(); 
  /*APP THEME UTILITY CLASS – EXPLANATION NOTES

1️⃣ Why Do We Write `AppTheme._();` ?
This is a private named constructor.

• `_` makes it private to the file.
• It prevents creating an instance of the class.
• It signals that this class is meant to be used as a utility holder.

Without it, someone could write:

  AppTheme();

But AppTheme is not meant to be instantiated.
It only holds configuration values (themes).

This pattern is commonly used for:
• Theme classes
• Constants classes
• Utility/helper classes

Interview Explanation:

“We use a private constructor to prevent instantiation of the theme class and enforce its usage as a static configuration container.”


2️⃣ Why Use `static` for ThemeData?

`static` means the variable belongs to the class itself, not to an instance.

Because we prevented instantiation using:

  AppTheme._();

We cannot create:

  AppTheme().lightTheme

So we declare:

  static ThemeData lightTheme

This allows us to access it directly using:

  AppTheme.lightTheme

without creating an object.

Interview Explanation:

“We declare theme configurations as static because the class acts as a utility container and should not require instantiation. Static members allow direct access via the class name.”


3️⃣ What Happens If We Remove `static`?

If we remove `static`:

• We would need an instance of AppTheme to access lightTheme.
• But instantiation is blocked by the private constructor.
• So the theme would become inaccessible.

Therefore:
Private constructor + static members = Proper utility class pattern.


4️⃣ What Does `scaffoldBackgroundColor` Do?

It sets the default background color for all Scaffold widgets in that theme.

So every screen using Scaffold will automatically have that background color.

This avoids manually setting background color in every screen. */

  static ThemeData lightTheme= ThemeData( //y static instead of const
    useMaterial3: true,
    brightness:Brightness.light,
    colorScheme: ColorScheme.fromSeed( //Better than manually setting primary colors. Auto-generates full Material 3 color system.Keeps consistency. Easy to change brand color later
      seedColor: Colors.deepPurple,
      brightness: Brightness.light,
      /*THEMEDATA.BRIGHTNESS vs COLORSCHEME.BRIGHTNESS – COMPLETE CLARITY NOTES

1️⃣ Why Do We Set Brightness in Both ThemeData and ColorScheme?

In Material 3, both ThemeData and ColorScheme influence how the app looks.

• ThemeData.brightness → Controls overall theme behavior.
• ColorScheme.brightness → Controls how the color palette is generated.

They serve different purposes and must be aligned.


2️⃣ What Does ThemeData.brightness Control?

ThemeData.brightness affects:

• Default text styles
• Icon themes
• AppBar defaults
• Scaffold behavior
• Component defaults

It tells Flutter whether the app is behaving as Light Mode or Dark Mode.


3️⃣ What Does ColorScheme.brightness Control?

ColorScheme.brightness determines how the color palette is generated.

When using:

ColorScheme.fromSeed(...)

Flutter generates:

• primary
• secondary
• surface
• background
• error
• and other semantic colors

The brightness parameter tells Flutter whether to generate a light or dark color system.


4️⃣ What Happens If They Are Mismatched?

If ThemeData.brightness and ColorScheme.brightness are not aligned:

• Color palette may be dark while theme behavior assumes light.
• Some widgets may use light defaults.
• Others may use dark-generated colors.
• Contrast inconsistencies can occur.
• UI may behave unpredictably.
• Text and surface colors may not align properly.

It may not always cause invisible text,
but it can cause inconsistent UI behavior.


5️⃣ Example of Proper Alignment

Light Theme:

ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.deepPurple,
    brightness: Brightness.light,
  ),
)

Dark Theme:

ThemeData(
  brightness: Brightness.dark,
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.deepPurple,
    brightness: Brightness.dark,
  ),
)


6️⃣ Interview-Level Explanation

“In Material 3, ColorScheme is the primary source of semantic colors, while ThemeData.brightness controls overall theme behavior and component defaults. If they are not aligned, the app may generate colors for one brightness mode while behaving as another, leading to inconsistent UI behavior. Therefore, both must be explicitly set to maintain visual consistency.” */
      ),
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0, /* Elevation represents the visual depth of a Material widget by applying a shadow. Higher elevation creates a stronger shadow, making the widget appear raised above others. Setting elevation to zero removes the shadow and creates a flat design appearance. */
    ),
  );

  static ThemeData darkTheme=ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.deepPurple,
      brightness: Brightness.dark,
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0
    )
  );
}

/*FLUTTER INTERNALS – COMPLETE MASTER REVISION NOTES
(Basic → Advanced → Product-Level Understanding)

────────────────────────────────────────
1️⃣ WHAT IS A PIXEL?
────────────────────────────────────────

Pixel = Smallest visible unit of a display.

Example:
A 1080 x 1920 screen contains:
1080 × 1920 = 2,073,600 pixels.

Each pixel stores:
• Red
• Green
• Blue
• Alpha (transparency)

Rendering means deciding what color each pixel should be.

This must happen ideally 60 times per second (60 FPS).


────────────────────────────────────────
2️⃣ WHAT IS GPU?
────────────────────────────────────────

GPU (Graphics Processing Unit) is hardware responsible for:
• Drawing pixels
• Rendering UI frames
• Applying shadows
• Applying blur
• Handling animations
• Compositing layers

CPU handles:
• Dart logic
• State updates
• Layout calculations

GPU handles:
• Final pixel drawing

Flutter:
CPU prepares frame → GPU renders frame


────────────────────────────────────────
3️⃣ WHAT IS RENDERING?
────────────────────────────────────────

Rendering = Converting UI description into actual pixels.

Flutter uses a layered pipeline:

Widget Tree → Element Tree → Render Tree → GPU


────────────────────────────────────────
4️⃣ WIDGET TREE (Configuration Layer)
────────────────────────────────────────

Widgets are:

• Immutable
• Lightweight
• Configuration objects
• Recreated frequently

Example:

Scaffold(
  appBar: AppBar(title: Text("My Habits")),
  body: ListView.builder(...),
)

Widgets do NOT draw anything.
They describe UI structure.


────────────────────────────────────────
5️⃣ ELEMENT TREE (Lifecycle & Identity Layer)
────────────────────────────────────────

Each Widget creates an Element.

Element responsibilities:
• Maintains identity
• Preserves state
• Manages lifecycle
• Compares old widget vs new widget
• Decides reuse vs recreate

Widget Type → Element Type:

StatelessWidget → StatelessElement
StatefulWidget → StatefulElement

Example:
Text → StatelessElement
Scaffold → StatefulElement

Elements are reused whenever possible.


────────────────────────────────────────
6️⃣ HOW setState() WORKS (REAL EXAMPLE)
────────────────────────────────────────

Checkbox(
  value: isCompleted,
  onChanged: (value) {
    setState(() {
      isCompleted = value!;
    });
  },
)

Process:
1. setState() triggers rebuild.
2. New widget objects are created.
3. Flutter compares old widget vs new widget.
4. If widget type matches → Element reused.
5. RenderObject updates paint.
6. UI updates.

Important:
Widgets are recreated.
Elements are reused.
RenderObjects are reused.


────────────────────────────────────────
7️⃣ WHAT DOES “TYPE MATCHES” MEAN?
────────────────────────────────────────

Type = runtime class of widget.

Old widget: Checkbox
New widget: Checkbox

Type matches → reuse Element.

Old widget: Checkbox
New widget: Text

Type changed → destroy old Element → create new Element.

Rebuild does NOT always mean destroy.


────────────────────────────────────────
8️⃣ WHAT IF setState() IS NOT CALLED?
────────────────────────────────────────

No rebuild.
No new widget created.
No comparison.
No element reuse triggered.

Nothing updates visually.


────────────────────────────────────────
9️⃣ RENDER TREE (Layout & Paint Layer)
────────────────────────────────────────

RenderObjects handle:

• Layout (size & position)
• Paint (draw shapes, text, colors)
• Hit testing

Examples:
Text → RenderParagraph
Container → RenderBox
ListView → RenderSliverList

RenderObjects are heavier than widgets.


────────────────────────────────────────
🔟 LISTVIEW PERFORMANCE & OFFSCREEN REUSE
────────────────────────────────────────

ListView.builder builds only visible items.

When scrolling:
• Offscreen elements may be removed.
• Elements may be recycled.
• Only visible render objects remain active.

This prevents building 1000 widgets at once.
Improves memory efficiency.


────────────────────────────────────────
1️⃣1️⃣ ELEVATION & PERFORMANCE
────────────────────────────────────────

Elevation adds:
• Shadow
• Surface tint (Material 3)
• Extra paint operations

Higher elevation → more shadow computation.

In large lists:
Too many elevated items → more GPU work → possible frame drops.

Single AppBar elevation → negligible impact.


────────────────────────────────────────
1️⃣2️⃣ DOES DARK COLOR AFFECT PERFORMANCE?
────────────────────────────────────────

No.

Solid colors are inexpensive to render.

Black pixels cost the same as white pixels.

Performance issues come from:
• Blur
• Shadows
• Opacity layers
• Overdraw
• Large images
• Excess rebuilds


────────────────────────────────────────
1️⃣3️⃣ WHAT IS BACKDROPFILTER?
────────────────────────────────────────

BackdropFilter applies effects (like blur) to background.

Blur is expensive because:
• GPU reads background pixels.
• Applies blur algorithm.
• Repaints result.

Heavy use can reduce frame rate.


────────────────────────────────────────
1️⃣4️⃣ FRAME TIMING & PERFORMANCE
────────────────────────────────────────

Each frame ideally completes within 16ms.

Frame phases:
• Build (widget creation)
• Layout (render tree)
• Paint
• Compositing
• GPU draw

If total time > 16ms → frame drop → lag.


────────────────────────────────────────
1️⃣5️⃣ WHY FLUTTER REBUILDS FREQUENTLY BUT REMAINS FAST
────────────────────────────────────────

Flutter remains fast because:

• Widgets are lightweight configuration objects.
• Rebuild creates new widgets but reuses existing Elements.
• If widget type matches, RenderObjects are reused.
• Layout & paint are skipped when unnecessary.
• GPU work only happens when visual changes occur.

Important correction:

Widgets are NOT reused.
Elements and RenderObjects are reused.

Rebuild is cheap, but not free.
Excessively rebuilding large subtrees can still impact performance.


────────────────────────────────────────
1️⃣6️⃣ WHY FLUTTER USES DECLARATIVE REBUILD INSTEAD OF MUTATION
────────────────────────────────────────

Flutter rebuilds configuration instead of mutating widgets because:

• Widgets are immutable.
• Immutable objects simplify comparison.
• Element tree handles efficient reuse.
• Makes UI predictable.
• Avoids complex mutation tracking logic.

Declarative rebuild → simpler + safer architecture.


────────────────────────────────────────
1️⃣7️⃣ COMPLETE PRODUCT-LEVEL INTERVIEW EXPLANATION
────────────────────────────────────────

“Flutter uses a layered rendering architecture. Widgets are immutable configuration objects that describe the UI. These are inflated into elements that manage lifecycle and preserve state. Elements connect to render objects responsible for layout and painting. When setState() is called, Flutter rebuilds widgets and compares them with previous ones. If the widget type matches, the existing element and render object are reused, ensuring efficient updates. After layout and paint phases, drawing commands are sent to the GPU to render pixels. Performance issues typically arise from excessive rebuilds, heavy layout computation, or expensive paint operations such as blur and shadow that increase frame time beyond 16 milliseconds.” */