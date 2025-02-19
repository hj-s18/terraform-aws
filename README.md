# launch template 생성하는 terraform 코드 수정하기

[Terraform 공식문서: Resource aws_launch_template](https://registry.terraform.io/providers/hashicorp/aws/2.40.0/docs/resources/launch_template#network-interfaces)

<br>
<br>
<br>

# 시작 탬플릿 만들 때 리소스 태그 추가하기

![image](https://github.com/user-attachments/assets/2fe088fc-4075-4739-bfe0-886b6b513c19)

<br>
<br>
<br>

# 문제 파악

현재 상황 <br>
1. 시작 템플릿 잘 생성함
2. 시작 템플릿으로 인스턴스도 잘 생성함
3. 노드 그룹 생성에서 오류남 ⇒ 노드그룹에 노드 없음 <br>

⇒ 노드 그룹이 시작 템플릿으로 만든 인스턴스를 자신의 노드로 인식하지 못함
⇒ userdata 사용해서 노드그룹이 인식하도록 해줘야 함!

<br>
<br>
<br>

# 전에 수동으로 만들었던 노드그룹에 있던 userdata 확인

```

```

