{
  lib,
  python3Packages,
  fetchFromGitHub,
  chafa,
  ffmpeg,
  fastfetch,
}:

# Upstream's own flake package traces its source on every evaluation and puts
# chafa/ffmpeg among the Python dependencies; the CLI tools go on PATH here.
python3Packages.buildPythonApplication rec {
  pname = "anifetch";
  version = "1.0.6";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "Notenlish";
    repo = "anifetch";
    tag = version;
    hash = "sha256-iNHYdS6NcmP2TxJNsh6uHDIuqattt9urb8Y+pFj5oak=";
  };

  build-system = [ python3Packages.setuptools ];

  dependencies = with python3Packages; [
    platformdirs
    wcwidth
    rich
    pynput
  ];

  makeWrapperArgs = [
    "--prefix PATH : ${
      lib.makeBinPath [
        chafa
        ffmpeg
        fastfetch
      ]
    }"
  ];

  meta = {
    description = "Animated terminal fetch with video and audio support";
    homepage = "https://github.com/Notenlish/anifetch";
    license = lib.licenses.mit;
    mainProgram = "anifetch";
  };
}
