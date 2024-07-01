import('smake/dependencyInstaller', true)

run('export MACOSX_DEPLOYMENT_TARGET=11.0') -- Doesn't work, need to do this before calling smake
InstallDependencies('ffmpeg', 'zlib', 'bzip2', 'lua')
run('rm dependencies/ffmpeg/**/math.h')