ManageIQ.angular.app.directive('fileread', function() {
  console.log('LOADED FILE READ DIRECTIVE')
  return {
    require: 'ngModel',
    scope: {
      fileread: '='
    },
    link: function (scope, elem, attr, ctrl) {
      elem.bind('change', function (changeEvent) {
        console.log('file changed...');
        var theFile = changeEvent.target.files[0];
        var reader = new FileReader();

        scope.$parent.fileDescriptor = theFile;

        reader.onload = function (readEvent) {
          if (readEvent.target.readyState === FileReader.DONE) {
            scope.$apply(function () {
              scope.fileread = new Uint8Array(readEvent.target.result);
            });
          }
        };

        reader.onerror = function (error) {
          console.error('Error occurred in fileread directive: ' + error);
        };

        reader.readAsArrayBuffer(theFile);
      });
    }
  }
});
