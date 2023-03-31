import 'package:flutter/material.dart';

missedTypeBadge(missedtype) {
  if (missedtype == 'missed') {
    return Padding(
      padding: const EdgeInsets.all(1.0),
      child: Container(
        width: 30.0,
        height: 30.0,
        decoration: BoxDecoration(
          color: Colors.orange[300],
          shape: BoxShape.circle,
        ),
        child: const Center(
          child: Text("F",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              )),
        ),
      ),
    );
  } else if (missedtype == 'late') {
    return Container(
      width: 30.0,
      height: 30.0,
      decoration: BoxDecoration(
        color: Colors.yellow[300],
        shape: BoxShape.circle,
      ),
      child: const Center(
        child: Text("V",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            )),
      ),
    );
  } else if (missedtype == 'none') {
    return Container(
      width: 30.0,
      height: 30.0,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        shape: BoxShape.circle,
      ),
      child: const Center(
        child: Text("A",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            )),
      ),
    );
  } else {
    return Container(
      width: 30.0,
      height: 30.0,
      decoration: BoxDecoration(
        color: Colors.purple[300],
        shape: BoxShape.circle,
      ),
      child: const Center(
        child: Text("Q",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            )),
      ),
    );
  }
}

contactedBadge(contacted) {
  if (contacted == true) {
    return Padding(
      padding: const EdgeInsets.all(1.0),
      child: Container(
        width: 30.0,
        height: 30.0,
        decoration: BoxDecoration(
          color: Colors.red[900],
          shape: BoxShape.circle,
        ),
        child: const Center(
          child: Text("K",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              )),
        ),
      ),
    );
  } else {
    return Container();
  }
}

returnedBadge(returned) {
  if (returned == true) {
    return Padding(
      padding: const EdgeInsets.all(1.0),
      child: Container(
        width: 30.0,
        height: 30.0,
        decoration: BoxDecoration(
          color: Colors.blue[600],
          shape: BoxShape.circle,
        ),
        child: const Center(
          child: Text("H",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              )),
        ),
      ),
    );
  } else {
    return Container();
  }
}

excusedBadge(excused) {
  if (excused == true) {
    return Padding(
      padding: const EdgeInsets.all(1.0),
      child: Container(
        width: 30.0,
        height: 30.0,
        decoration: BoxDecoration(
          color: Colors.red[900],
          shape: BoxShape.circle,
        ),
        child: const Center(
          child: Text("U",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              )),
        ),
      ),
    );
  } else {
    return Padding(
      padding: const EdgeInsets.all(1.0),
      child: Container(
        width: 30.0,
        height: 30.0,
        decoration: BoxDecoration(
          color: Colors.green[600],
          shape: BoxShape.circle,
        ),
        child: const Center(
          child: Text("E",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              )),
        ),
      ),
    );
  }
}
