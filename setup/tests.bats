@test "Check that the aws client prints usage instructions" {
  run aws
  [ $status -eq 2 ]
  [ $(expr "${lines[0]}" : "usage:") -ne 0 ]
}

@test "Check if $HOME/.aws/config exists" {
    [ -f $HOME/.aws/config ]
}

@test "Check that the terraform client is available" {
    terraform --version
}