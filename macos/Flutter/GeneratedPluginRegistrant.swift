//
//  Generated file. Do not edit.
//

import FlutterMacOS
import Foundation

import geolocator_apple
import location
import maps_launcher
import shared_preferences_macos
import url_launcher_macos

func RegisterGeneratedPlugins(registry: FlutterPluginRegistry) {
  GeolocatorPlugin.register(with: registry.registrar(forPlugin: "GeolocatorPlugin"))
  LocationPlugin.register(with: registry.registrar(forPlugin: "LocationPlugin"))
  MapsLauncherPlugin.register(with: registry.registrar(forPlugin: "MapsLauncherPlugin"))
  SharedPreferencesPlugin.register(with: registry.registrar(forPlugin: "SharedPreferencesPlugin"))
  UrlLauncherPlugin.register(with: registry.registrar(forPlugin: "UrlLauncherPlugin"))
}
