module Html.CssHelpers exposing (withNamespace, withClass, style, stylesheetLink, Namespace, Helpers)

{-| Helper functions for using elm-css with elm-html.

@docs withNamespace, withClass, style, stylesheetLink

@docs Helpers, Namespace
-}

import Css.Helpers exposing (toCssIdentifier, identifierToString)
import Html exposing (Attribute, Html)
import Html.Attributes as Attr
import String
import Tuple
import Json.Encode exposing (string)


{-| Prepend the given class name to a `Html.node` function's attributes list.

    import Html exposing (Html, Attribute, text)
    import Html.Attributes exposing (class)
    import Html.CssHelpers exposing (withClass)


    {-| Create a `button` variant that automatically includes a "warning" class.
    -}
    warningButton : List (Attribute msg) -> List (Html msg) -> Html msg
    warningButton =
        withClass "warning" button


    confirmDeleteButton : Html msg
    confirmDeleteButton =
        -- Equivalent to:
        --
        -- button [ class "warning" ] [ text "Confirm Deletion" ]
        warningButton [] [ text "Confirm Deletion" ]

Since `class` attributes "stack" in Elm (e.g.
`button [ class "warning", class "centered" ] []` is equivalent to
`button [ class "warning centered" ] []`), this API permits further
customization on a per-instance basis, either by using the `style` attribute
or by stacking additional classes
(for example `warningButton [ class "centered" ] []`).
-}
withClass : String -> (List (Attribute msg) -> List (Html msg) -> Html msg) -> List (Attribute msg) -> List (Html msg) -> Html msg
withClass className makeElem attrs =
    makeElem (Attr.class className :: attrs)


{-| Helpers for working on a given class/id
-}
type alias Helpers class id msg =
    { class : List class -> Attribute msg
    , classList : List ( class, Bool ) -> Attribute msg
    , id : id -> Attribute msg
    }


{-| namespaced helpers for working on a given class/id
-}
type alias Namespace name class id msg =
    { class : List class -> Attribute msg
    , classList : List ( class, Bool ) -> Attribute msg
    , id : id -> Attribute msg
    , name : name
    }


{-| Takes a namespace and returns helper functions for `id`, `class`, and
`classList` which work just like their equivalents in `elm-html` except that
they accept union types and automatically incorporate the given namespace. Also
note that `class` accepts a `List` instead of a single element; this is so you
can specify multiple classes without having to call `classList` passing tuples
that all end in `True`.

    -- Put this before your view code to specify a namespace.
    { id, class, classList } = withNamespace "homepage"

    view =
        h1 [ id Hero, class [ Fancy ] ] [ text "Hello, World!" ]

    type HomepageIds = Hero | SomethingElse | AnotherId
    type HomepageClasses = Fancy | AnotherClass | SomeOtherClass

The above would generate this DOM element:

    <h1 id="Hero" class="homepage_Fancy">Hello, World!</h1>
-}
withNamespace : name -> Namespace name class id msg
withNamespace name =
    { class = namespacedClass name
    , classList = namespacedClassList name
    , id = toCssIdentifier >> Attr.id
    , name = name
    }


helpers : Helpers class id msg
helpers =
    { class = class
    , classList = classList
    , id = toCssIdentifier >> Attr.id
    }


namespacedClassList : name -> List ( class, Bool ) -> Attribute msg
namespacedClassList name list =
    list
        |> List.filter Tuple.second
        |> List.map Tuple.first
        |> namespacedClass name


classList : List ( class, Bool ) -> Attribute msg
classList list =
    list
        |> List.filter Tuple.second
        |> List.map Tuple.first
        |> class


namespacedClass : name -> List class -> Attribute msg
namespacedClass name list =
    list
        |> List.map (identifierToString name)
        |> String.join " "
        |> Attr.class


class : List class -> Attribute msg
class =
    namespacedClass ""


{-| Create an inline style from CSS
-}
style : String -> Html msg
style text =
    Html.node "style"
        [ Attr.property "textContent" <| string text
        , Attr.property "type" <| string "text/css"
        ]
        []


{-| Link in a stylesheet from a url
-}
stylesheetLink : String -> Html msg
stylesheetLink url =
    Html.node "link"
        [ Attr.property "rel" (string "stylesheet")
        , Attr.property "type" (string "text/css")
        , Attr.property "href" (string url)
        ]
        []
