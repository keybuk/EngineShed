#  Coding Style

## Database Model

Key fields in an entity such as `title` should be marked non-optional, but given a default value of the empty string.

Scalar fields of `Bool`, `Int16`, etc. type should be non-optional with a default value.

Non-key fields should be optional, and `nil` saved instead of empty string.
