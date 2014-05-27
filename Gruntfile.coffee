module.exports = (grunt) ->
  grunt.loadNpmTasks('grunt-contrib-coffee')
  grunt.loadNpmTasks('grunt-contrib-watch')
  grunt.loadNpmTasks('grunt-jasmine-bundle')
  grunt.loadNpmTasks('grunt-contrib-uglify')
  grunt.loadNpmTasks('grunt-contrib-copy');
  
  grunt.registerTask(
    'default', 
    'Compiles the JavaScript files.', 
    [ 'coffee', 'copy', 'uglify' ]
  )

  grunt.initConfig
    spec:
      unit:
        options:
          minijasminenode:
            showColors: true
    watch:
      coffee:
        files: 'lib/*.coffee'
        tasks: ['coffee:compile']

    coffee:
      compile:
        expand: true,
        flatten: true,
        cwd: "#{__dirname}/lib/",
        src: ['*.coffee'],
        dest: 'js/',
        ext: '.js'
    copy:
      main:
        src: 'lib/angularBuilder.js'
        dest: 'dist/angularBuilder.js'
    uglify:
      dist:
        options:
          sourceMap: true
          sourceMapName: 'dist/angularBuilder.min.js.map'
        files:
          'dist/angularBuilder.min.js': ['js/angularBuilder.js']