# Fehlzeiten Client

!! WIP - not suitable for production!

## Description

This project is a flutter client to be used with the backend repository found here.

## History

The app was developed in autumn 2021 to follow real-time information about school attendance in our school.

## Real Name identities over QR-Code

In order to avoid the use of real names in the database, they are completely detached from it. The client imports the correspondence name<>pupil id via an encrypted qr code as a json file and saves it in the secure storage. None other information is locally stored.
 
The QR-Codes are encrypted in a computer of the school's local administrative network with an AES key. Key and IV are placed in the client `assets/keys` folder. the real names never leave the device.

## Features

Pupils can be marked as missed excused/unexcused, late (minutes), or picked up from school (e.g. for being sick) and at what time.

## Special features

Our school has a rewarding system with an own currency, which can be used to buy school T-Shirts, buttons, and more.
Through the app the pupil's "bank account" can be accessed and school-money used.