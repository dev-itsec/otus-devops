[master]
%{ for i in range(length(names_master)) ~}
${names_master[i]} ansible_host=${addrs_master[i]}
%{ endfor ~}

[ingress]
%{ for i in range(length(names_ingress)) ~}
${names_ingress[i]} ansible_host=${addrs_ingress[i]}
%{ endfor ~}

[node]
%{ for i in range(length(names_node)) ~}
${names_node[i]} ansible_host=${addrs_node[i]}
%{ endfor ~}
