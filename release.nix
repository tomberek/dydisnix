{ nixpkgs ? <nixpkgs> }:

let
  jobs = rec {
    tarball =
      { dydisnix ? {outPath = ./.; rev = 1234;}
      , officialRelease ? false
      }:

      with import nixpkgs {};

      releaseTools.sourceTarball {
        name = "dydisnix-tarball";
        version = builtins.readFile ./version;
        src = dydisnix;
        inherit officialRelease;

        buildInputs = [ pkgconfig getopt libxml2 glib disnix ]
          ++ lib.optional (!stdenv.isLinux) libiconv
          ++ lib.optional (!stdenv.isLinux) gettext;
      };

    build =
      { tarball ? jobs.tarball {}
      , system ? builtins.currentSystem
      }:

      with import nixpkgs { inherit system; };

      releaseTools.nixBuild {
        name = "dydisnix";
        src = tarball;
        
        buildInputs = [ pkgconfig getopt libxml2 glib disnix ]
                      ++ lib.optional (!stdenv.isLinux) libiconv
                      ++ lib.optional (!stdenv.isLinux) gettext;
      };

    tests = 
      { nixos ? <nixos> }:
      
      let
        dydisnix = build { system = "x86_64-linux"; };
        tests = ./tests;
      in
      with import "${nixos}/lib/testing.nix" { system = "x86_64-linux"; };
      
      {
        install = simpleTest {
          nodes = {
            machine =
              {config, pkgs, ...}:    
              
              {
                virtualisation.writableStore = true;
                environment.systemPackages = [ disnix dydisnix pkgs.stdenv ];
              };
          };
          testScript = ''
            # Test augment infra. For each target in the infrastructure model
            # we add the attribute: augment = "augment". This test should
            # succeed.
          
            my $result = $machine->mustSucceed("NIX_PATH='nixpkgs=${nixpkgs}' dydisnix-augment-infra -i ${tests}/infrastructure.nix -a ${tests}/augment.nix");
            $machine->mustSucceed("[ \"\$((NIX_PATH='nixpkgs=${nixpkgs}' nix-instantiate --eval-only --xml --strict $result) | grep 'augment')\" != \"\" ]");
            
            # Execute filter buildable. In this situation no build exceptions
            # occur, so all machines in the network are valid candidate hosts.
            # This test should succeed.
            
            my $result = $machine->mustSucceed("NIX_PATH='nixpkgs=${nixpkgs}' dydisnix-gendist --filter-buildable -s ${tests}/services.nix -i ${tests}/infrastructure.nix");
            my @distribution = split('\n', $machine->mustSucceed("cat $result"));
          
            if(@distribution[7] =~ /testtarget1/) {
                print "line 7 contains testtarget1!\n";
            } else {
                die "line 7 should contain testtarget1!\n";
            }
          
            if(@distribution[8] =~ /testtarget2/) {
                print "line 8 contains testtarget2!\n";
            } else {
                die "line 8 should contain testtarget2!\n";
            }
            
            if(@distribution[13] =~ /testtarget1/) {
                print "line 13 contains testtarget1!\n";
            } else {
                die "line 13 should contain testtarget1!\n";
            }
          
            if(@distribution[14] =~ /testtarget2/) {
                print "line 14 contains testtarget2!\n";
            } else {
                die "line 14 should contain testtarget2!\n";
            }
            
            if(@distribution[19] =~ /testtarget1/) {
                print "line 19 contains testtarget1!\n";
            } else {
                die "line 19 should contain testtarget1!\n";
            }
          
            if(@distribution[20] =~ /testtarget2/) {
                print "line 20 contains testtarget2!\n";
            } else {
                die "line 20 should contain testtarget2!\n";
            }
          
            # Execute filter buildable. In this situation a build exception is
            # thrown for testService1B rendering it undeployable.
            # This test should succeed.
            
            my $result = $machine->mustSucceed("NIX_PATH='nixpkgs=${nixpkgs}' dydisnix-gendist --filter-buildable -s ${tests}/services-error.nix -i ${tests}/infrastructure.nix");
            my @distribution = split('\n', $machine->mustSucceed("cat $result"));
          
            if(@distribution[7] =~ /testtarget1/) {
                die "line 7 contains testtarget1!\n";
            } else {
                print "line 7 should contain testtarget1!\n";
            }
          
            # Execute the mapAttrOnAttr method to map requireZone onto zone.
            # testService1 should be assigned to testtarget1. testService2 and
            # testService3 should be assigned to testtarget2. This test should
            # succeed.
            
            my $result = $machine->mustSucceed("NIX_PATH='nixpkgs=${nixpkgs}' dydisnix-gendist -s ${tests}/services.nix -i ${tests}/infrastructure.nix -q ${tests}/qos/qos-mapattronattr.nix");
            my @distribution = split('\n', $machine->mustSucceed("cat $result"));
            
            if(@distribution[7] =~ /testtarget1/) {
                print "line 7 contains testtarget1!\n";
            } else {
                die "line 7 should contain testtarget1!\n";
            }
            
            if(@distribution[12] =~ /testtarget1/) {
                print "line 12 contains testtarget1!\n";
            } else {
                die "line 12 should contain testtarget1!\n";
            }
            
            if(@distribution[17] =~ /testtarget2/) {
                print "line 17 contains testtarget2!\n";
            } else {
                die "line 17 should contain testtarget2!\n";
            }
          
            # Execute the mapAttrOnList method to map types onto supportedTypes.
            # All services must be assigned to both testtarget1 and testtarget2.
            # This test should succeed.
            
            my $result = $machine->mustSucceed("NIX_PATH='nixpkgs=${nixpkgs}' dydisnix-gendist -s ${tests}/services.nix -i ${tests}/infrastructure.nix -q ${tests}/qos/qos-mapattronlist.nix");
            my @distribution = split('\n', $machine->mustSucceed("cat $result"));
            
            if(@distribution[7] =~ /testtarget1/) {
                print "line 7 contains testtarget1!\n";
            } else {
                die "line 7 should contain testtarget1!\n";
            }
            
            if(@distribution[8] =~ /testtarget2/) {
                print "line 8 contains testtarget2!\n";
            } else {
                die "line 8 should contain testtarget2!\n";
            }
            
            if(@distribution[13] =~ /testtarget1/) {
                print "line 13 contains testtarget1!\n";
            } else {
                die "line 13 should contain testtarget1!\n";
            }
            
            if(@distribution[14] =~ /testtarget2/) {
                print "line 14 contains testtarget1!\n";
            } else {
                die "line 14 should contain testtarget1!\n";
            }
            
            if(@distribution[19] =~ /testtarget1/) {
                print "line 19 contains testtarget1!\n";
            } else {
                die "line 19 should contain testtarget1!\n";
            }
            
            if(@distribution[20] =~ /testtarget2/) {
                print "line 20 contains testtarget2!\n";
            } else {
                die "line 20 should contain testtarget2!\n";
            }
          
            # Execute the mapListOnAttr method to map requiredZones onto zones.
            # testService1 must be assigned to testtarget1. testService2 must be
            # assigned to testtarget2. testService3 must be assigned to both
            # machines. This test should succeed.
          
            my $result = $machine->mustSucceed("NIX_PATH='nixpkgs=${nixpkgs}' dydisnix-gendist -s ${tests}/services.nix -i ${tests}/infrastructure.nix -q ${tests}/qos/qos-maplistonattr.nix");
            my @distribution = split('\n', $machine->mustSucceed("cat $result"));
            
            if(@distribution[7] =~ /testtarget1/) {
                print "line 7 contains testtarget1!\n";
            } else {
                die "line 7 should contain testtarget1!\n";
            }
            
            if(@distribution[12] =~ /testtarget2/) {
                print "line 12 contains testtarget2!\n";
            } else {
                die "line 12 should contain testtarget2!\n";
            }
          
            if(@distribution[17] =~ /testtarget1/) {
                print "line 17 contains testtarget1!\n";
            } else {
                die "line 17 should contain testtarget1!\n";
            }
            
            if(@distribution[18] =~ /testtarget2/) {
                print "line 18 contains testtarget2!\n";
            } else {
                die "line 18 should contain testtarget2!\n";
            }
          
            # Execute the greedy division method. testService1 and testService2
            # should be assigned to testtarget2. testService3 should be assigned
            # to testtarget1. This test should succeed.
            
            my $result = $machine->mustSucceed("NIX_PATH='nixpkgs=${nixpkgs}' dydisnix-gendist -s ${tests}/services.nix -i ${tests}/infrastructure.nix -q ${tests}/qos/qos-greedy.nix");
            my @distribution = split('\n', $machine->mustSucceed("cat $result"));
            
            if(@distribution[7] =~ /testtarget1/) {
                print "line 7 contains testtarget1!\n";
            } else {
                die "line 7 should contain testtarget1!\n";
            }
            
            if(@distribution[12] =~ /testtarget1/) {
                print "line 12 contains testtarget1!\n";
            } else {
                die "line 12 should contain testtarget1!\n";
            }
            
            if(@distribution[17] =~ /testtarget2/) {
                print "line 17 contains testtarget2!\n";
            } else {
                die "line 17 should contain testtarget2!\n";
            }
            
            # Execute order. The targets are order by looking to the priority
            # attribute. The order of the targets should be reversed.
            # This test should succeed.
            
            my $result = $machine->mustSucceed("NIX_PATH='nixpkgs=${nixpkgs}' dydisnix-gendist -s ${tests}/services.nix -i ${tests}/infrastructure.nix -q ${tests}/qos/qos-order.nix");
            my @distribution = split('\n', $machine->mustSucceed("cat $result"));
            
            if(@distribution[7] =~ /testtarget2/) {
                print "line 7 contains testtarget2!\n";
            } else {
                die "line 7 should contain testtarget2!\n";
            }
            
            if(@distribution[8] =~ /testtarget1/) {
                print "line 8 contains testtarget1!\n";
            } else {
                die "line 8 should contain testtarget1!\n";
            }
            # Execute the highest bidder method. testService1 should be
            # assigned to testtarget2. testService2 should be assigned to
            # targettarget1. testService3 should be assigned to testtarget2.
            # This test should succeed.
            
            my $result = $machine->mustSucceed("NIX_PATH='nixpkgs=${nixpkgs}' dydisnix-gendist -s ${tests}/services.nix -i ${tests}/infrastructure.nix -q ${tests}/qos/qos-highest-bidder.nix");
            my @distribution = split('\n', $machine->mustSucceed("cat $result"));
            
            if(@distribution[7] =~ /testtarget2/) {
                print "line 7 contains testtarget2!\n";
            } else {
                die "line 7 should contain testtarget2!\n";
            }
            
            if(@distribution[12] =~ /testtarget1/) {
                print "line 12 contains testtarget1!\n";
            } else {
                die "line 12 should contain testtarget1!\n";
            }
            
            if(@distribution[17] =~ /testtarget2/) {
                print "line 17 contains testtarget2!\n";
            } else {
                die "line 17 should contain testtarget2!\n";
            }
            
            # Execute the lowest bidder method. testService1 and testService2
            # should be assigned to testtarget1. testService3 should be assinged
            # to testtarget2. This test should succeed.
            
            my $result = $machine->mustSucceed("NIX_PATH='nixpkgs=${nixpkgs}' dydisnix-gendist -s ${tests}/services.nix -i ${tests}/infrastructure.nix -q ${tests}/qos/qos-lowest-bidder.nix");
            my @distribution = split('\n', $machine->mustSucceed("cat $result"));
            
            if(@distribution[7] =~ /testtarget1/) {
                print "line 7 contains testtarget1!\n";
            } else {
                die "line 7 should contain testtarget1!\n";
            }
            
            if(@distribution[12] =~ /testtarget1/) {
                print "line 12 contains testtarget1!\n";
            } else {
                die "line 12 should contain testtarget1!\n";
            }
            
            if(@distribution[17] =~ /testtarget2/) {
                print "line 17 contains testtarget2!\n";
            } else {
                die "line 17 should contain testtarget2!\n";
            }
            
            # Execute minimum set cover approximation method, by looking to the
            # cost attribute in the infrastructure model. All services should
            # be distributed to testtarget1.
            
            my $result = $machine->mustSucceed("NIX_PATH='nixpkgs=${nixpkgs}' dydisnix-gendist -s ${tests}/services.nix -i ${tests}/infrastructure.nix -q ${tests}/qos/qos-minsetcover.nix");
            my @distribution = split('\n', $machine->mustSucceed("cat $result"));
            
            if(@distribution[7] =~ /testtarget1/) {
                print "line 7 contains testtarget1!\n";
            } else {
                die "line 7 should contain testtarget1!\n";
            }
            
            if(@distribution[12] =~ /testtarget1/) {
                print "line 12 contains testtarget1!\n";
            } else {
                die "line 12 should contain testtarget1!\n";
            }
            
            if(@distribution[17] =~ /testtarget1/) {
                print "line 17 contains testtarget1!\n";
            } else {
                die "line 17 should contain testtarget1!\n";
            }
            
            # Execute minimum set cover approximation method, by looking to the
            # cost attribute in the infrastructure model. testService1 and
            # testService2 should be distributed to testtarget1. testService3
            # should be distributed to testtarget2.
            
            my $result = $machine->mustSucceed("NIX_PATH='nixpkgs=${nixpkgs}' dydisnix-gendist -s ${tests}/services.nix -i ${tests}/infrastructure.nix -q ${tests}/qos/qos-minsetcover2.nix");
            my @distribution = split('\n', $machine->mustSucceed("cat $result"));
            
            if(@distribution[7] =~ /testtarget1/) {
                print "line 7 contains testtarget1!\n";
            } else {
                die "line 7 should contain testtarget1!\n";
            }
            
            if(@distribution[12] =~ /testtarget1/) {
                print "line 12 contains testtarget1!\n";
            } else {
                die "line 12 should contain testtarget1!\n";
            }
            
            if(@distribution[17] =~ /testtarget2/) {
                print "line 17 contains testtarget2!\n";
            } else {
                die "line 17 should contain testtarget2!\n";
            }
            
            # Execute multiway cut approximation method.
            # In this case all services should be mapped to testtarget1.
            # This test should succeed.
            
            my $result = $machine->mustSucceed("NIX_PATH='nixpkgs=${nixpkgs}' dydisnix-gendist -s ${tests}/services.nix -i ${tests}/infrastructure.nix -q ${tests}/qos/qos-multiwaycut.nix");
            my @distribution = split('\n', $machine->mustSucceed("cat $result"));
            
            if(@distribution[7] =~ /testtarget1/) {
                print "line 7 contains testtarget1!\n";
            } else {
                die "line 7 should contain testtarget1!\n";
            }
            
            if(@distribution[12] =~ /testtarget1/) {
                print "line 12 contains testtarget1!\n";
            } else {
                die "line 12 should contain testtarget1!\n";
            }
            
            if(@distribution[17] =~ /testtarget1/) {
                print "line 17 contains testtarget1!\n";
            } else {
                die "line 17 should contain testtarget1!\n";
            }
            
            # Execute map stateful to previous test. First, all services are
            # mapped to testtarget1. Then an upgrade is performed in which
            # services are mapped to all targets. testService1 which is marked
            # as stateful is only mapped to testtarget1. This test should
            # succeed.
            
            my $firstTargets = $machine->mustSucceed("NIX_PATH='nixpkgs=${nixpkgs}' dydisnix-gendist -s ${tests}/services.nix -i ${tests}/infrastructure.nix -q ${tests}/qos/qos-firsttargets.nix");
            my $result = $machine->mustSucceed("NIX_PATH='nixpkgs=${nixpkgs}' disnix-manifest -s ${tests}/services.nix -i ${tests}/infrastructure.nix -d $firstTargets");
            $machine->mustSucceed("mkdir /nix/var/nix/profiles/per-user/root/disnix-coordinator");
            $machine->mustSucceed("nix-env -p /nix/var/nix/profiles/per-user/root/disnix-coordinator/default --set $result");
            
            my $result = $machine->mustSucceed("NIX_PATH='nixpkgs=${nixpkgs}' dydisnix-gendist -s ${tests}/services.nix -i ${tests}/infrastructure.nix -q ${tests}/qos/qos-mapstatefultoprevious.nix");
            my @distribution = split('\n', $machine->mustSucceed("cat $result"));
            
            if(@distribution[7] =~ /testtarget1/) {
                print "line 7 contains testtarget1!\n";
            } else {
                die "line 7 should contain testtarget1!\n";
            }
            
            if(@distribution[8] =~ /testtarget2/) {
                die "line 8 contains testtarget2!\n";
            } else {
                print "line 8 does not contain testtarget2!\n";
            }
            
            # Execute graph coloring test. Each service should be mapped to a different machine.
            
            my $result = $machine->mustSucceed("NIX_PATH='nixpkgs=${nixpkgs}' dydisnix-gendist -s ${tests}/services.nix -i ${tests}/infrastructure-3.nix -q ${tests}/qos/qos-graphcol.nix");
            my @distribution = split('\n', $machine->mustSucceed("cat $result"));
            
            if(@distribution[7] =~ /testtarget1/) {
                print "line 7 contains testtarget1!\n";
            } else {
                die "line 7 should contain testtarget1!\n";
            }
            
            if(@distribution[12] =~ /testtarget2/) {
                print "line 12 contains testtarget2!\n";
            } else {
                die "line 12 should contain testtarget2!\n";
            }
            
            if(@distribution[17] =~ /testtarget3/) {
                print "line 17 contains testtarget3!\n";
            } else {
                die "line 17 should contain testtarget3!\n";
            }
          '';
        };
      };
  };
in jobs
