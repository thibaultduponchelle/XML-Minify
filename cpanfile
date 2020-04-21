requires 'perl', '5.010000';
requires 'Alien::Build', '==2.20';
requires 'Alien::Libxml2', '==0.15';
requires 'XML::LibXML', '==2.0204';

on 'test' => sub {
    requires 'Test::More', '0.98';
    requires 'Test::Slow', '0.04';
};

