ManageIQ.angular.app.controller('middlewareAddDeploymentController', MiddlewareDeploymentCtrl);

MiddlewareDeploymentCtrl.$inject = ['$scope', '$http', '$interval', "$location"];

function MiddlewareDeploymentCtrl($scope, $http, $interval, $location) {
  var self = this;
  $scope.vs = null;
  var d3 = window.d3;
  ManageIQ.angular.scope = $scope;

  $scope.showListener = function () {
    $scope.showDeployModal = true;
  };

  $scope.addDeployment = function () {
    var url = '/middleware_server/add_deployment';
    $scope.uploadFile($scope.fileDescriptor, url);
    /*
    $http.post(url, {"action" : "add_deployment", "resource" : "meh"}).success(function (response) {
      console.log('bazinga!', response);
    });
    */
  };
    
  $scope.uploadFile = function (file, uploadUrl) {
    var fd = new FormData();
    fd.append('file', file);
    fd.append('random', 'whatever');
    $http.post(uploadUrl, fd, {
      transformRequest: angular.identity,
      headers: {'Content-Type': undefined}
    })
    .success(function(){
    })
    .error(function(){
    });
  }

}
