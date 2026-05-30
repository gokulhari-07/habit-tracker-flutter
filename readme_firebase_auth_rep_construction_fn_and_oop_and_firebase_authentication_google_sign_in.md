# UNDERSTANDING FIREBASEAUTHREPOSITORY CONSTRUCTOR — COMPLETE OOP & DART FOUNDATION NOTES

════════════════════════════════════════════════════════════════════════════
TOPIC
════════════════════════════════════════════════════════════════════════════

Understanding this code deeply:

```dart
FirebaseAuthRepository({
  FirebaseAuth? firebaseAuth,
  GoogleSignIn? googleSignIn,
})  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
      _googleSignIn = googleSignIn ?? GoogleSignIn();
```

Goal:

* understand constructors
* understand `this`
* understand initializer list (`:`)
* understand private variables
* understand dependency
* understand dependency injection
* understand encapsulation
* understand why this architecture is used in production apps

════════════════════════════════════════════════════════════════════════════

1. WHAT IS A CLASS?
   ════════════════════════════════════════════════════════════════════════════

A class is:
✅ blueprint/template for creating objects.

Example:

```dart
class Person {
  String name = "Gokul";
}
```

This is only a blueprint.

═══════════════════════════════════════
OBJECT
═══════════════════════════════════════

```dart
final p = Person();
```

This creates actual object from blueprint.

Analogy:

Class = house design
Object = actual built house

════════════════════════════════════════════════════════════════════════════
2. WHAT IS A CONSTRUCTOR?
════════════════════════════════════════════════════════════════════════════

Constructor is:
✅ special function that runs automatically when object is created.

Example:

```dart
final p = Person();
```

When object created:
constructor runs automatically.

═══════════════════════════════════════
WHY CONSTRUCTORS EXIST
═══════════════════════════════════════

Purpose:
✅ initialize object data.

Without constructor:

```dart
class Person {
  String name = "";
}
```

Every object gets same empty value.

Not useful.

═══════════════════════════════════════
WITH CONSTRUCTOR
═══════════════════════════════════════

```dart
class Person {
  String name;

  Person(this.name);
}
```

Now:

```dart
Person("Gokul")
```

creates:

```text
name = "Gokul"
```

So constructor helps initialize object with custom values.

════════════════════════════════════════════════════════════════════════════
3. WHAT IS `this.name`?
════════════════════════════════════════════════════════════════════════════

Example:

```dart
class Person {
  String name;

  Person(this.name);
}
```

This is shorthand syntax.

═══════════════════════════════════════
WHAT HAPPENS INTERNALLY?
═══════════════════════════════════════

Conceptually Dart treats it similar to:

```dart
class Person {
  String name;

  Person(String name)
      : name = name;
}
```

LEFT SIDE:

```dart
name
```

= class variable

RIGHT SIDE:

```dart
name
```

= constructor parameter

Meaning:

Take incoming parameter
↓
Store into class variable

════════════════════════════════════════════════════════════════════════════
4. WHAT IS INITIALIZER LIST (`:`)?
════════════════════════════════════════════════════════════════════════════

THIS:

```dart
: variable = something
```

is called:
✅ initializer list.

Purpose:
✅ initialize variables BEFORE constructor body runs.

Especially useful for:

* final variables
* custom initialization logic
* dependency injection
* computed initialization

═══════════════════════════════════════
SIMPLE EXAMPLE
═══════════════════════════════════════

```dart
class Person {
  final String name;

  Person(String value)
      : name = value;
}
```

When:

```dart
Person("Gokul")
```

runs:

```text
value = "Gokul"
↓
name initialized BEFORE object creation finishes
```

═══════════════════════════════════════
WHY INITIALIZER LIST EXISTS
═══════════════════════════════════════

Because:
`final` variables MUST be initialized early.

Dart guarantees:
final variable never changes later.

════════════════════════════════════════════════════════════════════════════
5. DIFFERENCE BETWEEN `this.variable` AND `:`
════════════════════════════════════════════════════════════════════════════

═══════════════════════════════════════
USE `this.variable`
═══════════════════════════════════════

When:
✅ simple direct assignment only.

Example:

```dart
Person(this.name);
```

means:

```text
assign directly
```

═══════════════════════════════════════
USE `:`
═══════════════════════════════════════

When:
✅ extra logic needed.

Example:

```dart
Person(String value)
    : name = value.toUpperCase();
```

Now logic exists.

Cannot use:

```dart
this.name
```

for this.

═══════════════════════════════════════
IMPORTANT
═══════════════════════════════════════

Initializer list allows:

* logic
* transformations
* fallback values
* dependency injection
* complex initialization

════════════════════════════════════════════════════════════════════════════
6. WHAT IS `_variable` IN DART?
════════════════════════════════════════════════════════════════════════════

Example:

```dart
String _secret;
```

Leading underscore means:
✅ private variable.

Meaning:
accessible ONLY inside same file.

═══════════════════════════════════════
EXAMPLE
═══════════════════════════════════════

```dart
class Person {
  String _secret = "hidden";
}
```

Outside file:

```dart
person._secret
```

❌ ERROR

═══════════════════════════════════════
WHY PRIVATE VARIABLES USED?
═══════════════════════════════════════

Purpose:
✅ hide internal implementation
✅ protect internal state
✅ avoid misuse
✅ maintain encapsulation

════════════════════════════════════════════════════════════════════════════
7. WHAT IS ENCAPSULATION?
════════════════════════════════════════════════════════════════════════════

MOST IMPORTANT OOP CONCEPT.

Definition:

✅ Encapsulation = hiding internal implementation/details safely.

═══════════════════════════════════════
REAL WORLD ANALOGY — ATM MACHINE
═══════════════════════════════════════

You can:
✅ insert card
✅ withdraw money

But:
❌ cannot access bank server directly
❌ cannot touch database internally

Internal complexity hidden.

That is encapsulation.

═══════════════════════════════════════
PROGRAMMING EXAMPLE
═══════════════════════════════════════

WITHOUT encapsulation:

```dart
class BankAccount {
  int balance = 10000;
}
```

Anyone can do:

```dart
account.balance = -999999;
```

Dangerous.

═══════════════════════════════════════
BETTER VERSION
═══════════════════════════════════════

```dart
class BankAccount {
  int _balance = 10000;

  void deposit(int amount) {
    _balance += amount;
  }

  int getBalance() {
    return _balance;
  }
}
```

Now:
❌ cannot directly manipulate balance

Must use safe methods.

This is encapsulation.

═══════════════════════════════════════
PURPOSE OF ENCAPSULATION
═══════════════════════════════════════

✅ protect internal state
✅ prevent misuse
✅ hide complexity
✅ expose only safe APIs

Production apps heavily use encapsulation.

════════════════════════════════════════════════════════════════════════════
8. WHAT IS A DEPENDENCY?
════════════════════════════════════════════════════════════════════════════

Definition:

✅ Dependency = something another class NEEDS to work.

═══════════════════════════════════════
EXAMPLE
═══════════════════════════════════════

```dart
class Car {
  Engine engine;
}
```

Can car work without engine?

❌ No.

So:
Engine is dependency of Car.

═══════════════════════════════════════
REAL LIFE ANALOGY
═══════════════════════════════════════

Phone needs charger.

So:
charger = dependency.

════════════════════════════════════════════════════════════════════════════
9. WHAT IS DEPENDENCY INJECTION?
════════════════════════════════════════════════════════════════════════════

VERY IMPORTANT PRODUCTION CONCEPT.

═══════════════════════════════════════
BAD APPROACH
═══════════════════════════════════════

```dart
class Car {
  final Engine engine = Engine();
}
```

Problem:
❌ hardcoded
❌ difficult to replace
❌ difficult to test

═══════════════════════════════════════
GOOD APPROACH
═══════════════════════════════════════

```dart
class Car {
  final Engine engine;

  Car(this.engine);
}
```

Now:
engine comes from outside.

This is:
✅ dependency injection.

═══════════════════════════════════════
WHY CALLED INJECTION?
═══════════════════════════════════════

Because:
dependency supplied/injected from outside.

═══════════════════════════════════════
VISUAL
═══════════════════════════════════════

BAD:

```text
Car
 └── creates Engine internally
```

GOOD:

```text
Outside world
 └── gives Engine to Car
```

═══════════════════════════════════════
WHY THIS IS BETTER?
═══════════════════════════════════════

Now possible:

```dart
Car(SportsEngine())
Car(ElectricEngine())
Car(FakeEngine())
```

VERY flexible.

═══════════════════════════════════════
REAL BENEFIT
═══════════════════════════════════════

During testing:
we may NOT want real Firebase login.

We may want:
fake login system.

Dependency injection makes this possible.

════════════════════════════════════════════════════════════════════════════
10. APPLYING ALL THIS TO FIREBASEAUTHREPOSITORY
════════════════════════════════════════════════════════════════════════════

CODE:

```dart
final FirebaseAuth _firebaseAuth;
final GoogleSignIn _googleSignIn;
```

These are:
✅ dependencies.

Because repository NEEDS them to work.

═══════════════════════════════════════
WHY PRIVATE?
═══════════════════════════════════════

```dart
_firebaseAuth
```

is private because:
repository should fully control auth internally.

Outside world should NOT do:

```dart
repo._firebaseAuth.signOut()
```

That would break encapsulation.

═══════════════════════════════════════
CONSTRUCTOR
═══════════════════════════════════════

```dart
FirebaseAuthRepository({
  FirebaseAuth? firebaseAuth,
  GoogleSignIn? googleSignIn,
})
```

Meaning:

Optional dependencies may come from outside.

═══════════════════════════════════════
INITIALIZER LIST
═══════════════════════════════════════

```dart
: _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
  _googleSignIn = googleSignIn ?? GoogleSignIn();
```

Meaning:

IF custom dependency provided:
→ use it

ELSE:
→ use default SDK object

═══════════════════════════════════════
WHAT IS `??`
═══════════════════════════════════════

Null-coalescing operator.

Example:

```dart
name ?? "Guest"
```

Meaning:

IF name exists:
use name

ELSE:
use "Guest"

═══════════════════════════════════════
CURRENT FLOW IN APP
═══════════════════════════════════════

Current code:

```dart
FirebaseAuthRepository()
```

No custom dependency passed.

So:

```text
firebaseAuth == null
```

Therefore:

```dart
_firebaseAuth = FirebaseAuth.instance
```

═══════════════════════════════════════
TESTING EXAMPLE
═══════════════════════════════════════

Later possible:

```dart
FirebaseAuthRepository(
  firebaseAuth: FakeFirebaseAuth(),
)
```

Now:
fake dependency injected.

VERY useful for testing.

════════════════════════════════════════════════════════════════════════════
11. FINAL SIMPLE UNDERSTANDING
════════════════════════════════════════════════════════════════════════════

This repository is basically saying:

"I need FirebaseAuth and GoogleSignIn to work.

If someone provides custom ones,
I’ll use them.

Otherwise,
I’ll use default Firebase SDK instances."

════════════════════════════════════════════════════════════════════════════
12. MOST IMPORTANT TAKEAWAYS
════════════════════════════════════════════════════════════════════════════

✅ Constructor = initializes object during creation

✅ `this.variable` = shorthand direct assignment

✅ `:` initializer list = advanced initialization before constructor body

✅ `_variable` = private variable for encapsulation

✅ Encapsulation = hiding internal implementation/details safely

✅ Dependency = something class needs to work

✅ Dependency injection = supplying dependency from outside instead of creating internally

✅ Production apps use initializer lists heavily

✅ Production apps use dependency injection heavily

✅ Production apps use encapsulation heavily

These concepts are core foundations of scalable Flutter architecture.



INTERVIEW DEFINITIONS
════════════════════════════════════════════════════════════════════════════

* ENCAPSULATION:
Encapsulation is an OOP principle where a class hides its internal implementation and exposes only controlled access to its data or behavior. It helps protect internal state, reduce misuse, and maintain cleaner, safer architecture.

Example:
Using private variables (`_variable`) and public methods instead of directly exposing internal data.

════════════════════════════════════════════════════════════════════════════

* DEPENDENCY:
A dependency is any object or service that another class needs in order to function.

Example:
A FirebaseAuthRepository depends on FirebaseAuth to perform authentication operations.

════════════════════════════════════════════════════════════════════════════

DEPENDENCY INJECTION:
Dependency Injection is a design pattern where dependencies are provided to a class from outside instead of the class creating them internally. This improves flexibility, scalability, and testability.

Example:
Passing FirebaseAuth into FirebaseAuthRepository through the constructor instead of creating FirebaseAuth.instance directly inside the class.


# FIREBASE AUTHENTICATION & GOOGLE SIGN-IN — COMPLETE REVISION NOTES

════════════════════════════════════════════════════════════════════════════
GOAL OF THIS DOCUMENT
════════════════════════════════════════════════════════════════════════════

After reading this document, I should understand:

✅ How authentication works conceptually

✅ Difference between Google and Firebase

✅ What happens when user clicks Sign In

✅ What access token, ID token and refresh token are

✅ What session means

✅ What auth session means

✅ What authStateChanges() does

✅ Why Stream is used

✅ How Firebase remembers logged-in users

✅ What each function inside FirebaseAuthRepository does

✅ Full login flow from UI → Google → Firebase → App

════════════════════════════════════════════════════════════════════════════

1. FIRST UNDERSTAND AUTHENTICATION
   ════════════════════════════════════════════════════════════════════════════

Authentication means:

"Proving who the user is."

Example:

User says:

"I am Gokul."

App should verify:

"Are you really Gokul?"

That verification process is called:

AUTHENTICATION

═══════════════════════════════════════
REAL WORLD EXAMPLE
═══════════════════════════════════════

ATM Machine

You say:

"I own this bank account."

ATM says:

"Prove it."

You insert:

* ATM card
* PIN

ATM verifies identity.

Only then:

money can be accessed.

Same idea in apps.

════════════════════════════════════════════════════════════════════════════
2. WHO AUTHENTICATES USER IN OUR APP?
════════════════════════════════════════════════════════════════════════════

Important:

Our Flutter app DOES NOT authenticate user.

Google authenticates user.

Flow:

User
↓
Google
↓
Google verifies account ownership
↓
Google generates secure proof
↓
Firebase verifies Google proof
↓
Firebase creates app session
↓
App receives authenticated user

════════════════════════════════════════════════════════════════════════════
3. BIG PICTURE LOGIN FLOW
════════════════════════════════════════════════════════════════════════════

User clicks:

Sign In With Google

↓

Google account picker opens

↓

User selects account

↓

Google verifies account

↓

Google generates tokens

↓

App receives tokens

↓

Firebase verifies tokens

↓

Firebase creates session

↓

Firebase returns user

↓

UserEntity created

↓

UI updates automatically

════════════════════════════════════════════════════════════════════════════
4. FIREBASEAUTHREPOSITORY RESPONSIBILITY
════════════════════════════════════════════════════════════════════════════

FILE:

firebase_auth_repository.dart

Purpose:

This file is responsible for:

✅ Google login

✅ Firebase login

✅ Logout

✅ Auth state listening

✅ Converting Firebase User → UserEntity

It acts as bridge between:

Flutter App
↓
Firebase SDK
↓
Google SDK

════════════════════════════════════════════════════════════════════════════
5. UNDERSTANDING DEPENDENCIES USED
════════════════════════════════════════════════════════════════════════════

```dart
final FirebaseAuth _firebaseAuth;
final GoogleSignIn _googleSignIn;
```

These are dependencies.

Repository needs them to work.

═══════════════════════════════════════
WHAT IS FIREBASEAUTH?
═══════════════════════════════════════

Firebase SDK class.

Provides methods like:

```dart
authStateChanges()

signInWithCredential()

signOut()
```

═══════════════════════════════════════
WHAT IS GOOGLESIGNIN?
═══════════════════════════════════════

Google SDK class.

Provides methods like:

```dart
signIn()

signOut()
```

Responsible for:

* opening account picker
* communicating with Google

════════════════════════════════════════════════════════════════════════════
6. WHY DOES _firebaseAuth HAVE authStateChanges()?
════════════════════════════════════════════════════════════════════════════

Because:

```dart
final FirebaseAuth _firebaseAuth;
```

means:

_firebaseAuth is object of type FirebaseAuth.

And FirebaseAuth class already contains:

```dart
authStateChanges()
```

method.

Same as:

```dart
String name;

name.toUpperCase();
```

works because:

String class contains:

```dart
toUpperCase()
```

method.

Important rule:

Object can call methods belonging to its class.

════════════════════════════════════════════════════════════════════════════
7. authStateChanges() FUNCTION
════════════════════════════════════════════════════════════════════════════

Code:

```dart
Stream<UserEntity?> authStateChanges()
```

Purpose:

Listen continuously for:

✅ Login

✅ Logout

✅ Session restoration

═══════════════════════════════════════
INSIDE THIS FUNCTION
═══════════════════════════════════════

```dart
_firebaseAuth.authStateChanges()
```

returns:

```dart
Stream<User?>
```

Firebase emits values whenever auth state changes.

Example:

App starts:
→ User

Logout:
→ null

Login:
→ User

═══════════════════════════════════════
WHY STREAM?
═══════════════════════════════════════

Future:

One value once.

Example:

```dart
Future<String>
```

returns:

"Gokul"

once.

Done.

═══════════════════════════════════════

Stream:

Multiple values over time.

Example:

```text
User
↓
null
↓
User
↓
null
```

Auth state changes continuously.

Therefore Stream is perfect.

═══════════════════════════════════════
WHAT DOES .map() DO?
═══════════════════════════════════════

Firebase emits:

```dart
User
```

object.

App wants:

```dart
UserEntity
```

So:

```dart
.map((user) {})
```

transforms:

Firebase User
↓
UserEntity

════════════════════════════════════════════════════════════════════════════
8. signInWithGoogle() — COMPLETE FLOW
════════════════════════════════════════════════════════════════════════════

═══════════════════════════════════════
STEP 1
═══════════════════════════════════════

```dart
final googleUser =
    await _googleSignIn.signIn();
```

Purpose:

Open Google account picker.

User sees:

[gokul@gmail.com](mailto:gokul@gmail.com)
[work@gmail.com](mailto:work@gmail.com)

etc.

User selects account.

Google verifies account ownership.

═══════════════════════════════════════
RETURN VALUE
═══════════════════════════════════════

Returns:

```dart
GoogleSignInAccount
```

stored inside:

```dart
googleUser
```

Contains:

* email
* name
* id
* profile photo

═══════════════════════════════════════
NULL CHECK
═══════════════════════════════════════

```dart
if (googleUser == null)
```

This happens when:

User presses:

Cancel

instead of choosing account.

Then:

```dart
return null;
```

═══════════════════════════════════════
STEP 2
═══════════════════════════════════════

```dart
final googleAuth =
    await googleUser.authentication;
```

Purpose:

Retrieve tokens from Google.

Returns:

```dart
googleAuth.accessToken
googleAuth.idToken
```

════════════════════════════════════════════════════════════════════════════
9. WHAT ARE TOKENS?
════════════════════════════════════════════════════════════════════════════

Tokens are secure digital proof.

They prove:

"This user authenticated successfully."

═══════════════════════════════════════
ACCESS TOKEN
═══════════════════════════════════════

Think:

Temporary permission pass.

Used for:

* accessing Google services
* authorization

Short-lived.

═══════════════════════════════════════
ID TOKEN
═══════════════════════════════════════

Think:

Digital identity card.

Used to prove:

"This user is genuinely authenticated."

Firebase verifies it.

═══════════════════════════════════════
WHO GENERATES TOKENS?
═══════════════════════════════════════

Google Servers.

NOT our Flutter app.

Flow:

User logs into Google
↓
Google validates account
↓
Google generates tokens
↓
App receives tokens

════════════════════════════════════════════════════════════════════════════
10. WHAT IS GoogleAuthProvider?
════════════════════════════════════════════════════════════════════════════

Comes from:

```dart
import 'package:firebase_auth/firebase_auth.dart';
```

Firebase supports multiple providers:

* Google
* Apple
* GitHub
* Facebook

Each provider has:

```dart
GoogleAuthProvider
AppleAuthProvider
GithubAuthProvider
```

etc.

═══════════════════════════════════════
WHY NEEDED?
═══════════════════════════════════════

Firebase receives:

Google tokens.

Firebase wants:

Firebase credential.

GoogleAuthProvider converts:

Google tokens
↓
Firebase AuthCredential

═══════════════════════════════════════
STEP 3
═══════════════════════════════════════

```dart
final credential =
    GoogleAuthProvider.credential(
      accessToken: ...,
      idToken: ...,
    );
```

Purpose:

Wrap Google tokens into Firebase-compatible credential object.

Conceptually:

Google Language
↓
Translator
↓
Firebase Language

════════════════════════════════════════════════════════════════════════════
11. STEP 4 — ACTUAL FIREBASE LOGIN
════════════════════════════════════════════════════════════════════════════

```dart
await _firebaseAuth
    .signInWithCredential(
      credential,
    );
```

MOST IMPORTANT LINE.

This is where actual Firebase login happens.

═══════════════════════════════════════
WHAT HAPPENS INTERNALLY?
═══════════════════════════════════════

Firebase receives:

* access token
* ID token

Firebase asks Google:

"Is this token valid?"

Google verifies.

Google replies:

"Yes."

Firebase then:

✅ creates user session

✅ creates Firebase user

✅ stores auth session

✅ stores refresh token

════════════════════════════════════════════════════════════════════════════
12. WHAT IS A SESSION?
════════════════════════════════════════════════════════════════════════════

Session means:

User already proved identity.

Example:

Without session:

Open app
↓
Login
↓
Close app
↓
Login again

Very annoying.

═══════════════════════════════════════

With session:

Login once
↓
Close app
↓
Open app
↓
Still logged in

═══════════════════════════════════════

Session means:

"This user already authenticated."

════════════════════════════════════════════════════════════════════════════
13. WHAT IS AUTH SESSION?
════════════════════════════════════════════════════════════════════════════

Auth Session means:

Current authentication state.

Example:

UID = abc123

Email = [gokul@gmail.com](mailto:gokul@gmail.com)

Logged In = true

Firebase stores this state.

════════════════════════════════════════════════════════════════════════════
14. WHAT IS REFRESH TOKEN?
════════════════════════════════════════════════════════════════════════════

Access tokens expire.

Example:

1 hour.

Why?

Security.

═══════════════════════════════════════

Problem:

Should user login every hour?

No.

═══════════════════════════════════════

Solution:

Refresh Token.

Think:

Master Renewal Pass.

Flow:

Access Token expires
↓
Firebase uses Refresh Token
↓
Gets new Access Token
↓
User remains logged in

═══════════════════════════════════════

User never notices.

═══════════════════════════════════════

IMPORTANT:

Refresh token is NOT visible in our code.

Firebase SDK manages it automatically.

════════════════════════════════════════════════════════════════════════════
15. WHAT DOES FIREBASE STORE?
════════════════════════════════════════════════════════════════════════════

Internally Firebase stores:

* User UID
* Auth Session
* Refresh Token
* Provider Information

inside secure local storage.

Android:
Encrypted App Storage

iOS:
Keychain

════════════════════════════════════════════════════════════════════════════
16. WHY DOES LOGIN PERSIST AFTER APP RESTART?
════════════════════════════════════════════════════════════════════════════

App opens
↓
Firebase initializes
↓
Firebase checks stored auth session
↓
Refresh token valid?
↓
YES
↓
Firebase restores user
↓
authStateChanges emits user
↓
AuthController updates
↓
UI shows HomeScreen

No manual login needed.

════════════════════════════════════════════════════════════════════════════
17. signOut() FLOW
════════════════════════════════════════════════════════════════════════════

Code:

```dart
await _googleSignIn.signOut();

await _firebaseAuth.signOut();
```

═══════════════════════════════════════
GOOGLE SIGNOUT
═══════════════════════════════════════

Logs out from Google SDK.

Removes selected Google account session.

═══════════════════════════════════════
FIREBASE SIGNOUT
═══════════════════════════════════════

Logs out from Firebase session.

User becomes unauthenticated.

═══════════════════════════════════════
WHAT HAPPENS NEXT?
═══════════════════════════════════════

Firebase emits:

```text
null
```

through:

```dart
authStateChanges()
```

stream.

Then:

AuthController
↓
Riverpod
↓
AuthGateScreen

automatically rebuild.

User sees login screen again.

════════════════════════════════════════════════════════════════════════════
18. LIFECYCLE OF authStateChanges() STREAM
════════════════════════════════════════════════════════════════════════════

Stream starts listening when:

```dart
ref.watch(authControllerProvider)
```

first occurs.

═══════════════════════════════════════

In our app:

AuthGateScreen watches:

```dart
authControllerProvider
```

Therefore stream becomes active.

═══════════════════════════════════════

Listening continues during app lifetime.

═══════════════════════════════════════

When app closes:

Provider disposed
↓
Stream subscription cancelled
↓
Listening stops

════════════════════════════════════════════════════════════════════════════
19. MOST IMPORTANT INTERVIEW TAKEAWAYS
════════════════════════════════════════════════════════════════════════════

Google is responsible for:

✅ user identity verification

✅ generating tokens

═══════════════════════════════════════

Firebase is responsible for:

✅ verifying Google tokens

✅ creating auth session

✅ storing refresh token

✅ restoring login session

✅ emitting authStateChanges stream

═══════════════════════════════════════

Our app is responsible for:

✅ starting login flow

✅ converting Firebase User → UserEntity

✅ reacting to auth state changes

═══════════════════════════════════════

Most important authentication line:

```dart
await _firebaseAuth.signInWithCredential(
  credential,
);
```

This is where actual Firebase authentication happens.
