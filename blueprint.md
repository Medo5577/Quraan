# Quran App Blueprint

## Overview

A Flutter application to read the Quran.

## Features

*   Display a list of all Surahs.
*   Display the Ayahs of a selected Surah.
*   Theming with custom fonts and colors.

## Plan

1.  **Project Setup:**
    *   Add necessary dependencies:
        *   `http` for fetching Quran data from an API.
        *   `provider` for state management.
        *   `google_fonts` for custom fonts.
2.  **Data Layer:**
    *   Create a model class for the Quran data (Surah, Ayah).
    *   Create a service class to fetch Quran data from an API.
3.  **UI Layer:**
    *   Create a home screen to display the list of Surahs.
    *   Create a detail screen to display the Ayahs of a selected Surah.
    *   Implement a theme with custom fonts and colors.
4.  **State Management:**
    *   Use `provider` to manage the state of the app, including the list of Surahs and the selected Surah.
