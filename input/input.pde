// Imports
import java.io.*;
import java.util.*;
import java.sql.*;
import java.awt.Desktop;
import java.net.URI;
import processing.sound.*;
import controlP5.*;

// PApplet variable initialization
input myPApplet = this;

// Global variables declaration
int numberOfBands;
float []spectrumInitializer;
float []spectrum;
MicrophoneInput microphone;
Settings settings;
AnimationHandler animationHandler;
SettingsWindow settingsWindow;

void setup() {
    // Processing settings
    fullScreen(P3D);
    //size(1650, 800);
    smooth();
    colorMode(HSB, TWO_PI, 1.0, 1.0, 1);

    // Variables initialization
    numberOfBands = 1024;
    spectrumInitializer = new float[numberOfBands];
    spectrum = new float[2048];
    microphone = new MicrophoneInput();
    settings = new Settings();
    animationHandler = new AnimationHandler();
    settingsWindow = new SettingsWindow();

    // Defaults initialization
    settings.changeColor(255, 0, 0, 1);
    settings.changeColor(0, 255, 0, 2);
    settings.changeColor(0, 0, 0, 3);
    settingsWindow.initializeWindowComponents();
}

void draw() {
    // Updating the actual spectrum
    microphone.getFft().analyze(spectrumInitializer);
    spectrum = createSpectrum();

    // Setting the background
    int []backgroundColor = settings.getColor(3);
    color bgColor = rgbToHsb(backgroundColor[0],
                             backgroundColor[1],
                             backgroundColor[2], 255);
    background(bgColor);
    
    animationHandler.routeAnimation();
    if (settingsWindow.isVisibile()) {
        settingsWindow.showWindow();
    }
}

float[] createSpectrum() {
    float[] newSpectrum = new float[2048];
    int count = 0;

    /*
    for (int i = 0; i < 1535; i++) {
        if (i % 3 == 0 && i <= 1000) {
            newSpectrum[i] = spectrumInitializer[count];
        } else if (i > 1000 && i % 2 == 0) {
            newSpectrum[i] = spectrumInitializer[count];
        } else {
            newSpectrum[i] = spectrumInitializer[count];
            count++;
        }
    }
    */

    for (int i = 0; i < 2048; i += 2) {
        newSpectrum[i] = spectrumInitializer[count];
        newSpectrum[i + 1] = spectrumInitializer[count];
        count++;
    }

    return newSpectrum;
}

color rgbToHsb(int redColor, int greenColor, int blueColor, int alphaColor) {
    float r = float(redColor);
    float g = float(greenColor);
    float b = float(blueColor);

    float b_ = 0;
    float h = 0;
    float s = 0;

    float var_r = r / 255;
    float var_g = g / 255;
    float var_b = b / 255;

    float var_min = min(var_r, var_g, var_b);
    float var_max = max(var_r, var_g, var_b);
    float del_max = var_max - var_min;

    b_ = var_max;

    if (del_max == 0) {
        h = 0;
        s = 0;
    } else {
        s = del_max / var_max;

        float del_r = (((var_max - var_r) / 6) + (del_max / 2)) / del_max;
        float del_g = (((var_max - var_g) / 6) + (del_max / 2)) / del_max;
        float del_b = (((var_max - var_b) / 6) + (del_max / 2)) / del_max;

        if (var_r == var_max) {
            h = del_b - del_g;
        } else if (var_g == var_max) {
            h = (1.0 / 3.0) + del_r - del_b;
        } else if (var_b == var_max) {
            h = (2.0 / 3.0) + del_g - del_r;
        }

        if (h < 0) {
            h += 1;
        }
        if (h > 1) {
            h -= 1;
        }

        h = h * TWO_PI;
    }
    return color(h, s, b_, map(alphaColor, 0, 255, 0, 1));
}

void keyPressed() {
    if (key == 's' || key == 'S') {
        settingsWindow.changeVisibility();
    }
    // TODO: key to charge preset
}
