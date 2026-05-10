module LearningResourcesTest exposing (all)

import Expect
import LearningResources exposing (..)
import Test exposing (Test, describe, test)
import Yaml.Decode


yamlString : String
yamlString =
    """name: Java
description: Java is an Object Oriented language designed by James Gosling in 1995
emoji: '821822045187866625'
resources:
- name: Tutorial Spot
  url: https://www.tutorialspoint.com/java/index.htm
  pros: [ ]
  cons:
  - Slightly dated
- name: Alex Lee
  url: https://www.youtube.com/channel/UC_fFL5jgoCOrwAVoM_fBYwA
  pros:
  - Video series
  - Covers a wide range of concepts
  cons: [ ]
- name: Bro Code
  url: https://www.youtube.com/c/BroCodez
  pros:
  - Video series
  - Has videos on many different languages and concepts
  cons: [ ]
- name: Javatpoint
  url: https://www.javatpoint.com/java-tutorial
  pros: [ ]
  cons: [ ]
- name: Mooc.fi
  description: Comprehensive Java (and general programming) course provided by the University of Helsinki
  url: https://java-programming.mooc.fi/
  pros:
  - Very well respected
  cons: [ ]
- name: TheNewBoston
  url: https://www.youtube.com/@thenewboston
  pros:
  - Beginner and intermediate video series
  - Short, but a lot of videos (146 videos combined in both playlists)
  cons:
  - Videos may be outdated (2009 - 2012)"""


all : Test
all =
    describe "LearningResources"
        [ test "decodes java.yaml successfully" <|
            \_ ->
                case Yaml.Decode.fromString coordinate yamlString of
                    Ok result ->
                        Expect.all
                            [ \r -> Expect.equal "Java" r.name
                            , \r -> Expect.equal (Just "821822045187866625") r.emoji
                            , \r -> Expect.equal 6 (List.length r.resources)
                            ]
                            result

                    Err err ->
                        Expect.fail ("Decode failed: " ++ Yaml.Decode.errorToString err)
        , test "decodes resource with optional description" <|
            \_ ->
                case Yaml.Decode.fromString coordinate yamlString of
                    Ok result ->
                        let
                            mooc =
                                List.filter (\r -> r.name == "Mooc.fi") result.resources
                                    |> List.head
                        in
                        case mooc of
                            Just resource ->
                                Expect.equal
                                    (Just "Comprehensive Java (and general programming) course provided by the University of Helsinki")
                                    resource.description

                            Nothing ->
                                Expect.fail "Could not find Mooc.fi resource"

                    Err err ->
                        Expect.fail ("Decode failed: " ++ Yaml.Decode.errorToString err)
        , test "decodes resource without description as Nothing" <|
            \_ ->
                case Yaml.Decode.fromString coordinate yamlString of
                    Ok result ->
                        let
                            tutorial =
                                List.filter (\r -> r.name == "Tutorial Spot") result.resources
                                    |> List.head
                        in
                        case tutorial of
                            Just resource ->
                                Expect.equal Nothing resource.description

                            Nothing ->
                                Expect.fail "Could not find Tutorial Spot resource"

                    Err err ->
                        Expect.fail ("Decode failed: " ++ Yaml.Decode.errorToString err)
        , test "round-trips through encode and decode" <|
            \_ ->
                case Yaml.Decode.fromString coordinate yamlString of
                    Ok original ->
                        let
                            encoded =
                                coordinateToString original
                        in
                        case Yaml.Decode.fromString coordinate encoded of
                            Ok roundTripped ->
                                Expect.equal original.name roundTripped.name

                            Err err ->
                                Expect.fail ("Round-trip decode failed: " ++ Yaml.Decode.errorToString err)

                    Err err ->
                        Expect.fail ("Initial decode failed: " ++ Yaml.Decode.errorToString err)
        ]
