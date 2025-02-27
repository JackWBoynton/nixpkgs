{
  stdenv,
  lib,
  applyPatches,
  callPackage,
  cmake,
  fetchFromGitHub,
  fetchpatch,
  darwin,
  imgui,
  glfw,
  libGL,
  SDL2,
  vcpkg,
  hello-imgui,
  vulkan-headers,
  vulkan-loader,

  HELLOIMGUI_HAS_METAL ? stdenv.hostPlatform.isDarwin,
  HELLOIMGUI_HAS_VULKAN ? false,
  HELLOIMGUI_HAS_DIRECTX11 ? false,
  HELLOIMGUI_HAS_DIRECTX12 ? false,
  HELLOIMGUI_USE_GLFW3 ? true,
  HELLOIMGUI_HAS_OPENGL3 ? HELLOIMGUI_USE_SDL2 || HELLOIMGUI_USE_GLFW3,
  HELLOIMGUI_USE_SDL2 ? !HELLOIMGUI_USE_GLFW3 && !stdenv.hostPlatform.isDarwin,
  HELLOIMGUI_USE_FREETYPE ? false,

  withDemos ? false,
}@args:

let
  overriddenImgui = imgui.override { IMGUI_BUILD_GLFW_BINDING = HELLOIMGUI_USE_GLFW3; IMGUI_BUILD_OPENGL3_BINDING = HELLOIMGUI_HAS_OPENGL3; IMGUI_BUILD_SDL2_BINDING = HELLOIMGUI_USE_SDL2; IMGUI_FREETYPE = HELLOIMGUI_USE_FREETYPE; };
in

stdenv.mkDerivation rec {
  pname = "hello-imgui";
  version = "1.6.0";
  outputs = [ 
    "out"
  ];

  src = fetchFromGitHub {
    owner = "pthom";
    repo = "hello_imgui";
    rev = "v${version}";
    fetchSubmodules = true;
    hash = "sha256-TM8HV5sgalG+TvsghfH9qzJ+OGvuJn4V4EePoTxflwE=";
  };

  nativeBuildInputs = [ cmake ];

  buildInputs = lib.optionals stdenv.hostPlatform.isDarwin [
    darwin.apple_sdk.frameworks.ApplicationServices
    darwin.apple_sdk.frameworks.Cocoa
    darwin.apple_sdk.frameworks.GameController
  ];

  propagatedBuildInputs =
    [ overriddenImgui ] ++ lib.optionals HELLOIMGUI_USE_GLFW3 [ glfw ]
    ++ lib.optionals HELLOIMGUI_USE_SDL2 [ SDL2 ]
    ++ lib.optionals HELLOIMGUI_HAS_VULKAN [
      vulkan-headers
      vulkan-loader
    ]
    ++ lib.optionals HELLOIMGUI_HAS_METAL [ darwin.apple_sdk.frameworks.Metal ];

  cmakeFlags = [
    (lib.cmakeBool "HELLOIMGUI_USE_GLFW3" HELLOIMGUI_USE_GLFW3)
    (lib.cmakeBool "HELLOIMGUI_HAS_METAL" HELLOIMGUI_HAS_METAL)
    (lib.cmakeBool "HELLOIMGUI_HAS_VULKAN" HELLOIMGUI_HAS_VULKAN)
    (lib.cmakeBool "HELLOIMGUI_HAS_DIRECTX11" HELLOIMGUI_HAS_DIRECTX11)
    (lib.cmakeBool "HELLOIMGUI_HAS_DIRECTX12" HELLOIMGUI_HAS_DIRECTX12)
    (lib.cmakeBool "HELLOIMGUI_HAS_OPENGL3" HELLOIMGUI_HAS_OPENGL3)
    (lib.cmakeBool "HELLOIMGUI_USE_SDL2" HELLOIMGUI_USE_SDL2)
    (lib.cmakeBool "HELLOIMGUI_USE_FREETYPE" HELLOIMGUI_USE_FREETYPE)
    (lib.cmakeBool "HELLOIMGUI_USE_IMGUI_CMAKE_PACKAGE" true)
    (lib.cmakeBool "HELLOIMGUI_BUILD_DEMOS" withDemos)
  ];

  passthru.tests.examples = hello-imgui.override { withDemos = true; };

  meta = {
    description = "Hello, Dear ImGui: unleash your creativity in app development and prototyping";
    homepage = "https://github.com/pthom/hello_imgui";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [
      JackWBoynton
    ];
    platforms = lib.platforms.all;
  };

}